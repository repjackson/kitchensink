Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'me'


Template.nav.helpers
    user: -> Meteor.user()

Meteor.startup ->
    Session.setDefault 'selected_user', null
    Session.setDefault 'upvoted_cloud', null
    Session.setDefault 'downvoted_cloud', null
    Session.setDefault 'unvoted', null


Template.nav.events
    'click #home': ->
        selectedTags.clear()
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null
        Session.setDefault 'unvoted', null
        FlowRouter.go '/'

    'click #add_doc': ->
        Meteor.call 'create_doc', (err, id)->
            if err then console.log err
            else FlowRouter.go "/edit/#{id}"