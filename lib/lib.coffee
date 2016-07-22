@Tags = new Meteor.Collection 'tags'



Meteor.methods
    add_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag    
    
    remove_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag