
Template.profile.onCreated ->
    # @autorun -> Meteor.subscribe 'tags', []
    @autorun -> Meteor.subscribe 'me'
    # @autorun -> Meteor.subscribe 'people', selected_tags.array()

Template.profile.onRendered ->
    $('.ui.accordion').accordion()


Template.profile.helpers
    user_matches: ->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        user_matches = []
        for user in users
            tag_intersection = _.intersection(user.tags, Meteor.user().tags)
            user_matches.push
                matched_user: user.username
                tag_intersection: tag_intersection
                length: tag_intersection.length
        sortedList = _.sortBy(user_matches, 'length').reverse()
        return sortedList

    settings: ->
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    # token: ''
                    collection: Tags
                    field: 'name'
                    matchAll: false
                    template: Template.tag_result
                }
            ]
        }

    location_settings: ->
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    # token: ''
                    collection: Location_tags
                    field: 'name'
                    matchAll: false
                    template: Template.tag_result
                }
            ]
        }


    cloud_tag_class: -> if @name in selected_tags.array() then 'blue' else ''
    match_tag_class: -> if @valueOf() in selected_tags.array() then 'blue' else ''


Template.profile.events
    'keydown #add_tag': (e,t)->
        e.preventDefault
        if e.which is 13
            tag = $('#add_tag').val().toLowerCase().trim()
            if tag.length > 0
                Meteor.call 'add_tag', tag, ->
                    $('#add_tag').val('')

    # "autocompleteselect #add_tag": (event, template, doc)->
    #     Meteor.call 'add_tag', doc.name, ->
    #         $('#add_tag').val('')
        


    'keydown #location_tag': (e,t)->
        e.preventDefault
        location = $('#location_tag').val().toLowerCase().trim()
        if e.which is 13
            if location.length > 0
                Meteor.call 'check_in', location, ->
                    $('#location_tag').val('')


    'keydown #username': (e,t)->
        e.preventDefault
        username = $('#username').val().trim()
        switch e.which
            when 13
                if username.length > 0
                    Meteor.call 'update_username', username, (err,res)->
                        if err
                            swal 'Username exists.'
                            $('#username').val(Meteor.user().username)
                        else
                            swal "Updated username to #{username}."
    
    'keydown #contact': (e,t)->
        e.preventDefault
        contact = $('#contact').val().trim()
        switch e.which
            when 13
                if contact.length > 0
                    Meteor.call 'update_contact', contact, (err,res)->
                        if err then console.error err
                        else
                            swal "Updated contact to #{contact}."
    

    'click .my_tag': ->
        tag = @valueOf()
        Meteor.call 'remove_tag', tag, ->
            $('#add_tag').val(tag)

    'click .check_out': -> Meteor.call 'check_out'
    
    'click .check_in': (e,t)-> 
        # console.log @valueOf()
        # console.log e.currentTarget.valueOf()
        Meteor.call 'check_in', @valueOf()

    'click .user_tag': -> if @name in selected_tags.array() then selected_tags.remove(@name) else selected_tags.push(@name)
    
    'click .match_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())


Template.registerHelper 'person_intersection', ->
    me = Meteor.user()
    _.intersection(me.tags, @tags)


Template.friended_people.onCreated ->
    @autorun -> Meteor.subscribe 'friended_people'

Template.friended_people.helpers
    friended_people: -> 
        Meteor.users.find friends: $in: [Meteor.userId()]
        # Meteor.users.find()