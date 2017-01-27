Template.conversations.onCreated ->
    @autorun -> Meteor.subscribe('docs', selected_conversation_tags.array(), 'conversation')

Template.conversations.helpers
    conversations: -> Docs.find()


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
    conversation_tag_class: -> if @valueOf() in selected_conversation_tags.array() then 'red' else 'basic'

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


