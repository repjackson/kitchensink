Meteor.methods
    favorite: (doc)->
        if doc.favoriters and Meteor.userId() in doc.favoriters
            Docs.update doc._id,
                $pull: favoriters: Meteor.userId()
                $inc: favorite_count: -1
        else
            Docs.update doc._id,
                $addToSet: favoriters: Meteor.userId()
                $inc: favorite_count: 1
