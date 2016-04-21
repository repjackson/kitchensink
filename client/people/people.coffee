Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selectedUserTags.array())
    # @autorun -> Meteor.subscribe('docs', selectedUserTags.array())

Template.people.helpers
    people: -> Meteor.users.find({ _id: $ne: Meteor.userId() })
    # people: -> Meteor.users.find()
