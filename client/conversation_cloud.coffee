@selectedConversationTags = new ReactiveArray []

Template.conversation_cloud.onCreated ->
    @autorun -> Meteor.subscribe('conversation_tags', selectedConversationTags.array())

Template.conversation_cloud.helpers
    globaltags: ->
        # userCount = Meteor.users.find().count()
        # if 0 < userCount < 3 then tags.find { count: $lt: userCount } else tags.find()
        Conversationtags.find()

    globaltagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

    selectedConversationTags: -> selectedConversationTags.list()

    user: -> Meteor.user()



Template.conversation_cloud.events
    'click .selecttag': -> selectedConversationTags.push @name
    'click .unselecttag': -> selectedConversationTags.remove @valueOf()
    'click #cleartags': -> selectedConversationTags.clear()