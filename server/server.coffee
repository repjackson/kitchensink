Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        # console.log 'user ' + userId + 'wants to modify doc' + doc._id
        if userId and doc._id == userId
            # console.log 'user allowed to modify own account'
            true




Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret






