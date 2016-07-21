Meteor.publish 'inbox', ->
    Messages.find
        recipient_id: @userId
        
Meteor.publish 'outbox', ->
    Messages.find
        author_id: @userId