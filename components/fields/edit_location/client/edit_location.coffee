Template.edit_location.events
    'change #location': ->
        doc_id = FlowRouter.getParam('doc_id')
        location = $('#location').val()

        Docs.update doc_id,
            $set: location: location