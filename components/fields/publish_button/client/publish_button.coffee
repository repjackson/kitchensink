Template.publish_button.events
    'click #publish': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: published: true

    'click #unpublish': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: published: false
