@Tags = new Meteor.Collection 'tags'


Meteor.methods
    remove_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag

    add_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag

    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username
