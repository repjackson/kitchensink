FlowRouter.route '/people_cards', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'people_cards'







if Meteor.isClient
    Template.people_cards.onCreated ->
        @autorun -> Meteor.subscribe('people', selected_user_tags.array())
    
    
    Template.people_cards.helpers
        people: -> 
            Meteor.users.find { _id: $ne: Meteor.userId() }, 
                sort:
                    tag_count: 1
                limit: 10
    
        tag_class: -> if @valueOf() in selected_user_tags.array() then 'primary' else ''



if Meteor.isServer
    Meteor.publish 'people', (selected_user_tags)->
        match = {}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        match._id = $ne: @userId
        Meteor.users.find match,
            limit: 20
