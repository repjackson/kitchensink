@selectedTags = new ReactiveArray []

Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags', selectedTags.array())

Template.cloud.helpers
    globalTags: ->
        userCount = Meteor.users.find().count()
        if 0 < userCount < 3 then Tags.find { count: $lt: userCount } else Tags.find()
        # Tags.find()

    # globalTagClass: ->
    #     buttonClass = switch
    #         when @index <= 20 then 'big'
    #         when @index <= 40 then 'large'
    #         when @index <= 60 then ''
    #         when @index <= 80 then 'small'
    #         when @index <= 100 then 'tiny'
    #     return buttonClass

    globalTagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

    selectedTags: -> selectedTags.list()

    user: -> Meteor.user()



Template.cloud.events
    'click .selectTag': -> selectedTags.push @name
    'click .unselectTag': -> selectedTags.remove @valueOf()
    'click #clearTags': -> selectedTags.clear()

