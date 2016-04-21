Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selectedTraits.array())

Template.people.helpers
    # people: -> Meteor.users.find({ _id: $ne: Meteor.userId() })
    people: -> Meteor.users.find()


Template.person.onCreated ->
    # Meteor.subscribe 'person', @data._id
    # if @data._id then console.log 'dataId', @data._id

Template.person.helpers
    isUser: -> @_id is Meteor.userId()

    traitClass: ->
        if @valueOf() in selectedTraits.array() then 'primary' else 'basic'

    userDocTagClass: ->
        if @valueOf() in selectedTraits.array() then 'primary' else 'basic'


Template.person.events
    'click .trait': ->
        if @valueOf() in selectedTraits.array() then selectedTraits.remove @valueOf() else selectedTraits.push @valueOf()
