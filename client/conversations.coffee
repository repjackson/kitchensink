Template.conversations.events
    'click #create_conversation': ->
        Meteor.call 'create_conversation', (err, id)->
            if err
                console.log err
            else
                FlowRouter.go "/editConversation/#{id}"

Template.conversations.onCreated ->
    @autorun -> Meteor.subscribe('conversations', selectedConversationTags.array())

Template.conversations.helpers
    conversations: -> Conversations.find()


# Single
Template.conversation.onCreated ->
    @autorun -> Meteor.subscribe('conversationMessages', @_id)

Template.conversation.helpers
    tagClass: ->
        if @valueOf() in selectedConversationTags.array() then 'primary' else 'basic'

    inConversation: -> if Meteor.userId() in @participants then true else false

    conversationMessages: -> Messages.find(conversationId: @_id)

Template.conversation.events
    'click .tag': ->
        if @valueOf() in selectedConversationTags.array() then selectedConversationTags.remove @valueOf() else selectedConversationTags.push @valueOf()

    'click .joinConversation': -> console.log @

    'keydown .addMessage': (e,t)->
        e.preventDefault
        switch e.which
            when 13
                text = $('.addMessage').val().trim()
                if text.length > 0
                    Meteor.call 'add_message', text, @_id, (err,res)->
