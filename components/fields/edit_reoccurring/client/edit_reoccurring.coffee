Template.edit_reoccurring.events
    'click #make_reoccurring': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: reoccurring: true

    'click #make_unreoccurring': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: reoccurring: false
