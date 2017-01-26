Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.edit.helpers
    item: ->
        Docs.findOne FlowRouter.getParam('doc_id')
    

        
        
Template.edit.events
    'click #save': ->
        FlowRouter.go "/view/#{@_id}"
