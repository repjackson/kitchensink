Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selectedTags.array())

Template.people.helpers
    people: -> Meteor.users.find({})
