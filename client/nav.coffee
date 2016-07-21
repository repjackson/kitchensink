Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'me'


Template.nav.helpers

Meteor.startup ->
    Session.setDefault 'selected_user', null
    Session.setDefault 'upvoted_cloud', null
    Session.setDefault 'downvoted_cloud', null
    Session.setDefault 'unvoted', null


Template.nav.events
    'click #home': ->
        selected_doc_tags.clear()
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null
        Session.setDefault 'unvoted', null
        FlowRouter.go '/'

    'click #add_doc': ->
        Meteor.call 'create_doc', (err, id)->
            if err then console.log err
            else FlowRouter.go "/docs/edit/#{id}"

    'click .select_bookmark': ->
        selected_doc_tags.clear()
        selected_doc_tags.push(tag) for tag in @

    'click .add_from_bookmark': ->
        Meteor.call 'create_doc_with_tags', @, (err,id)->
            if err then console.log err
            else FlowRouter.go "/docs/edit/#{id}"


    'click .toggleSidebar': ->
        $('.ui.sidebar').sidebar 'toggle'

    'click #store_menu_item': ->
        selected_doc_tags.clear()
        selected_doc_tags.push('store')
        FlowRouter.go '/'

    'click #new_from_selection': ->
        # if confirm 'Create new document from selection?'
        Meteor.call 'create_doc', selected_doc_tags.array(), (err,id)->
            if err then console.log err
            else FlowRouter.go "/docs/edit/#{id}"
