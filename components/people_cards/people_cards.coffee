FlowRouter.route '/people_cards', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'people_cards'







if Meteor.isClient
    Template.people_cards.onCreated ->
        @autorun -> Meteor.subscribe('people', selected_user_tags.array())
    Template.person_card.onCreated ->
        @autorun -> Meteor.subscribe('person', @_id)
    
    
    Template.people_cards.helpers
        people: -> 
            Meteor.users.find { _id: $ne: Meteor.userId() }, 
                sort:
                    tag_count: 1
                limit: 10
    
        tag_class: -> if @valueOf() in selected_user_tags.array() then 'primary' else ''

    Template.person_card.events
        'click .user_tag': ->
            if @valueOf() in selected_user_tags.array() then selected_user_tags.remove @valueOf() else selected_user_tags.push @valueOf()

    Template.person_card.helpers
        five_tags: -> if @tags then @tags[..4]
    


if Meteor.isServer
    Meteor.publish 'people', (selected_user_tags)->
        match = {}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        match._id = $ne: @userId
        Meteor.users.find match,
            limit: 20
    
    
