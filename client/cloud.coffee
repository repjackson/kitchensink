@selectedTraits = new ReactiveArray []

Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('traits', selectedTraits.array())

Template.cloud.helpers
    globalTraits: ->
        # userCount = Meteor.users.find().count()
        # if 0 < userCount < 3 then Traits.find { count: $lt: userCount } else Traits.find()
        Traits.find()
#
    # globalTraitClass: ->
    #     buttonClass = switch
    #         when @index <= 20 then 'big'
    #         when @index <= 40 then 'large'
    #         when @index <= 60 then ''
    #         when @index <= 80 then 'small'
    #         when @index <= 100 then 'tiny'
    #     return buttonClass

    globalTraitClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

    selectedTraits: -> selectedTraits.list()

    user: -> Meteor.user()



Template.cloud.events
    'click .selectTrait': -> selectedTraits.push @name
    'click .unselectTrait': -> selectedTraits.remove @valueOf()
    'click #clearTraits': -> selectedTraits.clear()