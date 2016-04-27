Template.conversations.onCreated ->
    @autorun -> Meteor.subscribe('conversations', selectedConversationTags.array())

Template.conversations.helpers
    conversations: -> Conversations.find()


# Single
Template.conversation.onCreated ->
    @autorun -> Meteor.subscribe('conversationMessages', Template.currentData()._id)
    @autorun -> Meteor.subscribe('usernames')

Template.conversation.helpers
    tagClass: ->
        if @valueOf() in selectedConversationTags.array() then 'primary' else 'basic'

    inConversation: -> if Meteor.userId() in @participantIds then true else false

    conversationMessages: -> Messages.find({conversationId: @_id})

Template.conversation.events
    'click .tag': ->
        if @valueOf() in selectedConversationTags.array() then selectedConversationTags.remove @valueOf() else selectedConversationTags.push @valueOf()

    'click .joinConversation': -> console.log @

    'keydown .addMessage': (e,t)->
        e.preventDefault
        switch e.which
            when 13
                text = t.find('.addMessage').value.trim()
                if text.length > 0
                    Meteor.call 'add_message', text, @_id, (err,res)->
                        t.find('.addMessage').value = ''

    'click .createEvent': ->
        tags = @tags
        Meteor.call 'create_event', tags, (err, res)->
            FlowRouter.go '/events'
            selectedEventTags.clear()
            selectedEventTags.push(tag) for tag in tags
