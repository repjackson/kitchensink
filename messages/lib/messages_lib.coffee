@Messages = new Meteor.Collection 'messages'
@Conversations = new Meteor.Collection 'conversations'


Messages.helpers
    author: -> Meteor.users.findOne @author_id
    recipient: -> Meteor.users.findOne @recipient_id
    when: -> moment(@timestamp).fromNow()


Meteor.methods
    send_message: (body, recipient_id) ->
        Messages.insert
            timestamp: Date.now()
            author_id: Meteor.userId()
            body: body
            recipient_id: recipient_id
