Template.edit_post.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')

Template.edit_post.helpers
    post: ->
        Docs.findOne FlowRouter.getParam('doc_id')
    
        
Template.edit_post.events
    'click #save_post': ->
        title = $('#title').val()
        publish_date = $('#publish_date').val()
        description = $('#description').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                title: title
                publish_date: publish_date
                description: description
        FlowRouter.go "/post/view/#{@_id}"