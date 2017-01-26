if Meteor.isClient
    $.cloudinary.config
        cloud_name:"facet"




if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret
    
