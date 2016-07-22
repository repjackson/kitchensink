@Tags = new Meteor.Collection 'tags'
@Location_tags = new Meteor.Collection 'location_tags'
@Active_locations = new Meteor.Collection 'active_locations'



Meteor.methods
    add_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag    
    
    remove_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag
            
    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username

    update_contact: (contact)->
        Meteor.users.update Meteor.userId(),
            $set: contact: contact

    check_in: (location)->
        existing_location = Location_tags.findOne name: location
        if not existing_location
            Location_tags.insert name: location
        Meteor.users.update Meteor.userId(), 
            $addToSet: location_tags: location
            $set: active_location: location
            
    check_out: ->
        Meteor.users.update Meteor.userId(),
            $unset: active_location: ''
