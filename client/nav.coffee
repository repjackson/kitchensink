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


    'click .toggleSidebar': ->
        $('.ui.sidebar').sidebar 'toggle'

    'click #store_menu_item': ->
        selectedTags.clear()
        selectedTags.push('store')
        FlowRouter.go '/'

    'click #newFromSelection': ->
        # if confirm 'Create new document from selection?'
        Meteor.call 'createDoc', selectedTags.array(), (err,id)->
            if err then console.log err
            else FlowRouter.go "/edit/#{id}"
