@Conversation_tags = new Meteor.Collection 'conversation_tags'



FlowRouter.route '/conversations', action: (params) ->
    BlazeLayout.render 'layout',
        cloud: 'conversation_cloud'
        main: 'conversations'

FlowRouter.route '/conversation/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'conversation_page'



Meteor.methods
    create_conversation: (tags=[])->
        Docs.insert
            tags: tags
            type: 'conversation'
            author_id: Meteor.userId()
            participant_ids: [Meteor.userId()]
        # FlowRouter.go "/conversation/#{id}"

    close_conversation: (id)->
        Docs.remove id
        Messages.remove conversation_id: id

    join_conversation: (id)->
        Docs.update id,
            $addToSet:
                participant_ids: Meteor.userId()

    leave_conversation: (id)->
        Docs.update id,
            $pull:
                participant_ids: Meteor.userId()






if Meteor.isClient
    Template.conversations.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_conversation_tags.array(), 'conversation')
    
    Template.conversations.helpers
        conversations: -> 
            Docs.find
                type: 'conversation'
    
    Template.conversations.events
        'click #create_conversation': ->
            Meteor.call 'create_conversation', (err,id)->
                FlowRouter.go "/conversation/#{id}"

    
    # Single
    
    Template.conversation_card.onCreated ->
        @autorun -> Meteor.subscribe('conversation_messages', Template.currentData()._id)
        @autorun -> Meteor.subscribe('people_list', Template.currentData()._id)
    
    Template.conversation_card.helpers
        conversation_messages: -> Messages.find({conversation_id: @_id})
    
        participants: ->
            participant_array = []
            for participant in @participant_ids?
                participant_object = Meteor.users.findOne participant
                participant_array.push participant_object
            return participant_array
    
    
    
    Template.conversation_card.helpers
        conversation_tag_class: -> if @valueOf() in selected_conversation_tags.array() then 'primary' else 'basic'
    
    Template.conversation_card.events
        'click .remove_message': ->
            self = @
            swal {
                title: "Remove Message?"
                # text: 'You will not be able to recover this imaginary file!'
                type: 'warning'
                showCancelButton: true
                animation: false
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Remove'
                closeOnConfirm: true
            }, ->
                Messages.remove self._id
                # console.log self
                # swal "Submission Removed", "",'success'
                # return
    
    
if Meteor.isServer
    Meteor.publish 'conversation_messages', (conversation_id) ->
        Messages.find
            conversation_id: conversation_id
