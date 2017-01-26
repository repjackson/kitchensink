Template.edit_event.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.edit_event.helpers
    event: ->
        Docs.findOne FlowRouter.getParam('doc_id')
    

        
        
Template.edit_event.events
    'click #save_event': ->
        start_datetime = $('#start_datetime').val()
        end_datetime = $('#end_datetime').val()
        
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                start_datetime: start_datetime
                end_datetime: end_datetime

        FlowRouter.go "/event/view/#{@_id}"
