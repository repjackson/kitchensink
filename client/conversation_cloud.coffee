@selectedConversationTags = new ReactiveArray []

Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('people_tags', selectedConversationTags.array())

Template.cloud.helpers
    globaltags: ->
        # userCount = Meteor.users.find().count()
        # if 0 < userCount < 3 then tags.find { count: $lt: userCount } else tags.find()
        Tags.find()
#
    # globaltagClass: ->
    #     buttonClass = switch
    #         when @index <= 20 then 'big'
    #         when @index <= 40 then 'large'
    #         when @index <= 60 then ''
    #         when @index <= 80 then 'small'
    #         when @index <= 100 then 'tiny'
    #     return buttonClass

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



Template.cloud.events
    'click .selecttag': -> selectedConversationTags.push @name
    'click .unselecttag': -> selectedConversationTags.remove @valueOf()
    'click #cleartags': -> selectedConversationTags.clear()