Template.edit_tags.events
    'keydown #add_tag': (e,t)->
        if e.which is 13
            doc_id = FlowRouter.getParam('doc_id')
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Docs.update doc_id,
                    $addToSet: tags: tag
                $('#add_tag').val('')

    'click .doc_tag': (e,t)->
        organization = Docs.findOne FlowRouter.getParam('doc_id')
        tag = @valueOf()
        Docs.update FlowRouter.getParam('doc_id'),
            $pull: tags: tag
        $('#add_tag').val(tag)
