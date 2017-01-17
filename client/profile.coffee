Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'me'



Template.profile.helpers



Template.profile.events
    'click #save_profile': ->
        FlowRouter.go "/"

    'blur #name': ->
        name = $('#name').val()
        Meteor.users.update Meteor.userId(),
            $set: name: name
            

    'keydown #add_tag': (e,t)->
        if e.which is 13
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Meteor.users.update Meteor.userId(),
                    $addToSet: tags: tag
                $('#add_tag').val('')

    'click .person_tag': (e,t)->
        tag = @valueOf()
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag
        $('#add_tag').val(tag)



    "change input[type='file']": (e) ->
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
                    Meteor.users.update Meteor.userId(),
                        $set: image_id: res.public_id
                return

    'click #pick_google_image': ->
        picture = Meteor.user().profile.google_image
        Meteor.call 'download_image', picture, (err, res)->
            if err
                console.error err
            else
                console.log typeof res
                Cloudinary.upload res,
                    # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                    # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                    (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                        # console.log "Upload Error: #{err}"
                        # console.dir res
                        if err
                            console.error 'Error uploading', err
                        else
                            console.log 'i think this worked'
                            Meteor.users.update Meteor.userId(), 
                                $set: "profile.image_id": res.public_id
                        return


    'click #remove_photo': ->
        Meteor.users.update Meteor.userId(),
            $unset: image_id: 1
