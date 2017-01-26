Template.page.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'page', self.data.page

Template.page.helpers
    page: -> Docs.findOne {}

Template.page.events
    'click #edit_page': ->
        id = Docs.findOne()._id
        FlowRouter.go "/page/edit/#{id}"