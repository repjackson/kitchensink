
Template.favorites.onCreated ->
    @autorun -> Meteor.subscribe 'favorites'



Template.favorites.helpers
    favorites: -> Docs.find()

Template.favorites.events


