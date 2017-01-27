Template.conversation_page.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')
        self.subscribe('conversation_messages', FlowRouter.getParam('doc_id'))
        self.subscribe('people_list', FlowRouter.getParam('doc_id'))


Template.conversation_page.helpers
    conversation: -> 
        Docs.findOne FlowRouter.getParam('doc_id')

    in_conversation: -> if Meteor.userId() in @participant_ids then true else false

    # conversation_messages: -> Messages.find({conversation_id: @_id})
    conversation_messages: -> Messages.find()

    
    participants: ->
        participant_array = []
        for participant in @participant_ids
            participant_object = Meteor.users.findOne participant
            participant_array.push participant_object
        return participant_array


Template.conversation_page.events
    'click .join_conversation': -> Meteor.call 'join_conversation', @_id
    'click .leave_conversation': -> Meteor.call 'leave_conversation', @_id

    'keydown .add_message': (e,t)->
        id = FlowRouter.getParam('doc_id')
        e.preventDefault
        if e.which is 13
            text = t.find('.add_message').value.trim()
            if text.length > 0
                Meteor.call 'add_message', text, id, (err,res)->
                    t.find('.add_message').value = ''

    'click .close_conversation': ->
        self = @
        swal {
            title: "Close Conversation?"
            text: 'This will also delete the messages'
            type: 'warning'
            showCancelButton: true
            animation: false
            confirmButtonColor: '#DD6B55'
            confirmButtonText: 'Close'
            closeOnConfirm: true
        }, ->
            Meteor.call 'close_conversation', self._id, ->
                FlowRouter.go '/conversations'
            # console.log self
            # swal "Submission Removed", "",'success'
            return


