Template.delete_button.events
    'click #delete': ->
        swal {
            title: 'Delete?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, ->
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            Docs.remove doc._id, ->
                FlowRouter.go "/#{doc.type}s"
