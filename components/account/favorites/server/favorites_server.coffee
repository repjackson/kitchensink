Meteor.publish 'favorites', ->
    Docs.find
        favoriters: $in: [@userId]