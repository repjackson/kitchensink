Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'me'


Template.nav.helpers
    user: -> Meteor.user()



Template.nav.events
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
