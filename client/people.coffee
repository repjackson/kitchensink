@selected_tags = new ReactiveArray []
# @selected_active_location_tags = new ReactiveArray []
Session.setDefault 'active_location', false


Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selected_tags.array(), Session.get('active_location'))
    @autorun -> Meteor.subscribe('tags', selected_tags.array(), Session.get('active_location'))
    # @autorun -> Meteor.subscribe('location_tags', selected_tags.array(), Session.get('active_location'))
    # @autorun -> Meteor.subscribe('active_locations', selected_tags.array(), Session.get('active_location'))


Template.people.helpers
    people: -> 
        match = {}
        if selected_tags.array().length > 0 then match.tags = $all: selected_tags.array()
        match._id = $ne: Meteor.userId()
        
        Meteor.users.find match
        # Meteor.users.find({ })

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''


Template.person.onCreated ->
    # console.log Template.currentData()
    # @autorun -> Meteor.subscribe('person', Template.currentData()._id)

Template.person.helpers
    person_tag_class: -> if @valueOf() in selected_tags.array() then 'blue' else 'basic'
    
    is_friend: -> if Meteor.user().friends and @_id in Meteor.user().friends then true else false
    


Template.person.events
    'click .person_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

    'keydown #tag_person': (e,t)->
        # console.log @
        e.preventDefault
        tag = $('#tag_person').val().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Meteor.call 'tag_person', @_id, tag
