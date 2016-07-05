@Tags = new Meteor.Collection 'tags'


Meteor.methods
    remove_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag

    add_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag

