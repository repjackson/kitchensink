Template.edit_title.events
    'blur #title': ->
        title = $('#title').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: title: title