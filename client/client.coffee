
Template.people.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_people_tags.array()
    @autorun -> Meteor.subscribe 'me'



Template.profile.onCreated ->
    @autorun -> Meteor.subscribe('self_doc')
    
Template.profile.helpers
    user_matches: ->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        user_matches = []
        for user in users
            tag_intersection = _.intersection(user.list, Meteor.user().list)
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
                    matchAll: true
                    template: Template.tag_result
                }
            ]
        }


    my_tags: -> 
        self_review = Docs.findOne
            recipient_id: Meteor.userId()
            author_id: Meteor.userId()
        if self_review
            self_review.tags
        else
            []
            
    cloud_tag_class: -> if @name in selected_people_tags.array() then 'blue' else ''
    match_tag_class: -> if @valueOf() in selected_people_tags.array() then 'blue' else ''


Template.profile.events
    'keydown #self_tag': (e,t)->
        e.preventDefault
        tag = $('#self_tag').val().toLowerCase().trim()
        if e.which is 13
            if tag.length > 0
                Meteor.call 'tag_user', Meteor.userId(), tag, ->
                    $('#self_tag').val('')


    'keydown #username': (e,t)->
        e.preventDefault
        username = $('#username').val().trim()
        switch e.which
            when 13
                if username.length > 0
                    Meteor.call 'update_username', username, (err,res)->
                        if err
                            alert 'Username exists.'
                            $('#username').val(Meteor.user().username)
                        else
                            alert "Updated username to #{username}."
    
    'keydown #contact': (e,t)->
        e.preventDefault
        contact = $('#contact').val().trim()
        switch e.which
            when 13
                if contact.length > 0
                    Meteor.call 'update_contact', contact, (err,res)->
                        if err then console.error err
                        else
                            alert "Updated contact to #{contact}."
    

    'click .my_tag': ->
        tag = @valueOf()
        Meteor.call 'remove_tag', Meteor.userId(), tag, ->
            $('#self_tag').val(tag)

    'click .user_tag': -> if @name in selected_people_tags.array() then selected_people_tags.remove(@name) else selected_people_tags.push(@name)
    
    'click .match_tag': -> if @valueOf() in selected_people_tags.array() then selected_people_tags.remove(@valueOf()) else selected_people_tags.push(@valueOf())


Template.registerHelper 'person_intersection', ->
    me = Meteor.user()
    _.intersection(me.list, @list)


Template.people_you_like.onCreated ->
    @autorun -> Meteor.subscribe('people_you_like')

Template.people_you_like.helpers
    people_you_like: -> 
        if Meteor.user()?.people_you_like
            Meteor.users.find { _id: $in: Meteor.user().people_you_like },
                fields:
                    username: 1
                    cloud: 1
                    list: 1
                    contact: 1
        else []
    
Template.people_who_like_you.onCreated ->
    @autorun -> Meteor.subscribe('people_who_like_you')

Template.people_who_like_you.helpers
    people_who_like_you: -> 
        Meteor.users.find { people_you_like: $in: [Meteor.userId()] },
        # Meteor.users.find { },
            fields:
                username: 1
                cloud: 1
                list: 1
                contact: 1
    
