Template.received_messages.onCreated ->
    @autorun -> Meteor.subscribe 'received_messages'

Template.sent_messages.onCreated ->
    @autorun -> Meteor.subscribe 'sent_messages'
    @autorun -> Meteor.subscribe('people', [])


Template.sent_messages.helpers
    sent_messages: -> Messages.find( author_id: Meteor.userId() )

    userSettings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Meteor.users
                field: 'profile.name'
                template: Template.user_pill
            }
        ]
    }


Template.received_messages.helpers
    received_messages: -> Messages.find( recipient_id: Meteor.userId() )


Template.sent_messages.events
    'click #send': (e)->
        body = $('#text').val()
        recipient_name = $('#recipient').val()
        # console.log 'recipient', recipient
        recipient_id = Meteor.users.findOne({"profile.name": recipient_name})._id
        Meteor.call 'send_message', body, recipient_id


