Template.edit_page.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.edit_page.helpers
    page: ->
        Docs.findOne FlowRouter.getParam('doc_id')
    

        
        
Template.edit_page.events
    'click #save_page': ->
        FlowRouter.go "/#{@name}"





