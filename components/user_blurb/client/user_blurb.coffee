Template.user_blurb.onCreated ->
    @autorun -> Meteor.subscribe('person', Template.parentData().author_id)

Template.user_blurb.helpers
    person: -> Meteor.users.findOne()
