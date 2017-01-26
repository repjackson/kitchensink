Template.edit_type.events
    'blur #type': ->
        type = $('#type').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: type: type