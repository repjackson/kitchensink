Template.edit_image.events
    "change input[type='file']": (e) ->
        doc_id = FlowRouter.getParam('doc_id')
        files = e.currentTarget.files


        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                # console.log "Upload Error: #{err}"
                # console.dir res
                if err
                    console.error 'Error uploading', err
                else
                    Docs.update doc_id, $set: image_id: res.public_id
                return

    'keydown #input_image_id': (e,t)->
        if e.which is 13
            doc_id = FlowRouter.getParam('doc_id')
            image_id = $('#input_image_id').val().toLowerCase().trim()
            if image_id.length > 0
                Docs.update doc_id,
                    $set: image_id: image_id
                $('#input_image_id').val('')



    'click #remove_photo': ->
        swal {
            title: 'Remove Photo?'
            type: 'warning'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'No'
            confirmButtonText: 'Remove'
            confirmButtonColor: '#da5347'
        }, =>
            Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                if not err
                    # Do Stuff with res
                    # console.log res
                    Docs.update FlowRouter.getParam('doc_id'), 
                        $unset: image_id: 1

                else
                    throw new Meteor.Error "it failed miserably"

    #         console.log Cloudinary
    # 		Cloudinary.delete "37hr", (err,res) ->
    # 		    if err 
    # 		        console.log "Upload Error: #{err}"
    # 		    else
    #     			console.log "Upload Result: #{res}"
    #                 # Docs.update FlowRouter.getParam('doc_id'), 
    #                 #     $unset: image_id: 1


            
            
            
# Template.edit_image.helpers
#     log: -> console.log @