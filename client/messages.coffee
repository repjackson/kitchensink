Template.received_messages.onCreated ->
    @autorun -> Meteor.subscribe 'received_messages'

Template.sent_messages.onCreated ->
    @autorun -> Meteor.subscribe 'sent_messages'
    @autorun -> Meteor.subscribe('people', [])


Template.sent_messages.helpers
    sent_messages: -> Messages.find( authorId: Meteor.userId() )

    userSettings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Meteor.users
                field: 'username'
                template: Template.userPill
            }
        ]
    }


Template.received_messages.helpers
    received_messages: -> Messages.find( recipientId: Meteor.userId() )


Template.sent_messages.events
    'click #send': (e)->
        body = $('#text').val()
        recipientUsername = $('#recipient').val()
        # console.log 'recipient', recipient
        recipientId = Meteor.users.findOne({username: recipientUsername})._id
        Meteor.call 'send_message', body, recipientId


