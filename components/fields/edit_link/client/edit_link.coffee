Template.edit_link.events
    'blur #link': ->
        link = $('#link').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: link: link