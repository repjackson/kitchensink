Template.edit_name.events
    'blur #name': ->
        name = $('#name').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: name: name