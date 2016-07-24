@selected_tags = new ReactiveArray []
# @selected_active_location_tags = new ReactiveArray []
Session.setDefault 'active_location', false


Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selected_tags.array(), Session.get('active_location'))
    @autorun -> Meteor.subscribe('tags', selected_tags.array(), Session.get('active_location'))
    # @autorun -> Meteor.subscribe('location_tags', selected_tags.array(), Session.get('active_location'))
    @autorun -> Meteor.subscribe('active_locations', selected_tags.array(), Session.get('active_location'))


Template.people.helpers
    people: -> 
        Meteor.users.find({ _id: $ne: Meteor.userId() })
        # Meteor.users.find({ })

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''


Template.person.onCreated ->
    # console.log Template.currentData()
    # @autorun -> Meteor.subscribe('person', Template.currentData()._id)

Template.person.helpers
    person_tag_class: -> if @valueOf() in selected_tags.array() then 'blue' else ''
    
    is_friend: -> if Meteor.user().friends and @_id in Meteor.user().friends then true else false
    


Template.person.events
    'click .person_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

    'click .friend': -> 
        username = @username
        Meteor.call 'friend', @_id, ->
            swal 
                title: "Friended #{username}. #{username} can now see your contact info."
                animation: false
                timer: 2000
                showConfirmButton: false
            
            
    'click .unfriend': -> 
        username = @username
        Meteor.call 'unfriend', @_id, ->
            swal 
                title: "Unfriended #{username}.  #{username} can no longer see your contact info."
                animation: false
                timer: 2000
                showConfirmButton: false