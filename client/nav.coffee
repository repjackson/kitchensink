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


Template.nav.events
    'click #home': ->
        selectedTags.clear()
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null


    'click #addDoc': ->
        Meteor.call 'createDoc', (err, id)->
            if err then console.log err
            else FlowRouter.go "/edit/#{id}"

    'click .selectBookmark': ->
        selectedTags.clear()
        selectedTags.push(tag) for tag in @

    'click .addFromBookmark': ->
        Meteor.call 'createDoc', @, (err,id)->
            if err then console.log err
            else FlowRouter.go "/edit/#{id}"

    'click #mine': ->
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null
        Session.set 'selected_user', Meteor.userId()

    'click #my_upvoted': ->
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', Meteor.userId()

    'click #my_downvoted': ->
        Session.set 'selected_user', null
        Session.set 'upvoted_cloud', null
        Session.set 'downvoted_cloud', Meteor.userId()
