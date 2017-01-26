Template.page_view.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')



Template.page_view.helpers
    item: ->
        Docs.findOne FlowRouter.getParam('doc_id')

    ecosystem_tags: ->
        _.without(@tags, 'ecosystem') 



Template.page_view.events
    'click .edit': ->
        doc_id = FlowRouter.getParam('doc_id')
        FlowRouter.go "/edit/#{doc_id}"
