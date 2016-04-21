Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selectedTraits.array())
    @autorun -> Meteor.subscribe('me')

Template.people.helpers
    # people: -> Meteor.users.find({ _id: $ne: Meteor.userId() })
    people: -> Meteor.users.find()


Template.person.onCreated ->
    # Meteor.subscribe 'person', @data._id


Template.person.helpers
    isUser: -> @_id is Meteor.userId()

    traitClass: ->
        if @valueOf() in selectedTraits.array() then 'primary' else 'basic'

    matchedTraits: ->
        console.log Meteor.user().traits
        _.intersection @traits, Meteor.user().traits


Template.person.events
    'click .trait': ->
        if @valueOf() in selectedTraits.array() then selectedTraits.remove @valueOf() else selectedTraits.push @valueOf()
