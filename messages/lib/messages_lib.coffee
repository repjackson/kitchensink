@Messages = new Meteor.Collection 'messages'


Messages.helpers
    author: -> Meteor.users.findOne @author_id
    recipient: -> Meteor.users.findOne @recipient_id
    when: -> moment(@timestamp).fromNow()


Meteor.methods
    send_message: (username, body, tags) ->
        id = Meteor.users.findOne(username: username)._id
        Messages.insert
            timestamp: Date.now()
            author_id: Meteor.userId()
            body: body
            recipient_id: id
            tags: tags