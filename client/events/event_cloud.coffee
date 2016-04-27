@selectedEventTags = new ReactiveArray []

Template.event_cloud.onCreated ->
    @autorun -> Meteor.subscribe('event_tags', selectedEventTags.array())

Template.event_cloud.helpers
    globaltags: ->
        # userCount = Meteor.users.find().count()
        # if 0 < userCount < 3 then tags.find { count: $lt: userCount } else tags.find()
        Eventtags.find()

    globaltagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

    selectedEventTags: -> selectedEventTags.list()

    user: -> Meteor.user()



Template.event_cloud.events
    'click .selecttag': -> selectedEventTags.push @name
    'click .unselecttag': -> selectedEventTags.remove @valueOf()
    'click #cleartags': -> selectedEventTags.clear()