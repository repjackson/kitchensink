Meteor.publish 'conversation_messages', (conversation_id) ->
    Messages.find
        conversation_id: conversation_id
