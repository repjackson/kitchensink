Template.favorite.helpers
    favorite_count: -> Template.parentData(0).favorite_count
    
    favorite_item_class: -> 
        if Meteor.userId()
            if Template.parentData(0).favoriters and Meteor.userId() in Template.parentData(0).favoriters then 'red' else 'outline'
        else 'grey disabled'
    
Template.favorite.events
    'click .favorite_item': -> 
        if Meteor.userId() then Meteor.call 'favorite', Template.parentData(0)
        else FlowRouter.go '/sign-in'
