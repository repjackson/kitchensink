Template.conversations.events
    'click #create_conversation': ->
        Meteor.call 'create_conversation', (err, id)->
            if err
                console.log err
            else
                FlowRouter.go "/editConversation/#{id}"
