@selected_tags = new ReactiveArray []


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    dropdownClasses: 'simple'


Template.layout.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_tags.array()
    @autorun -> Meteor.subscribe 'me'

Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selected_tags.array())


Template.people.helpers
    people: -> 
        Meteor.users.find({ _id: $ne: Meteor.userId() })
        # Meteor.users.find({ })

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''


Template.cloud.helpers
    globalTags: ->
        user_count = Meteor.users.find().count()
        # console.log user_count
        if user_count < 3 then Tags.find({ count: $lt: user_count }, limit: 20 ) else Tags.find({}, limit: 50 )
        # Tags.find({}, limit: 25)

    # cloud_tag_class: ->
    #     buttonClass = switch
    #         when @index <= 5 then 'large'
    #         when @index <= 10 then ''
    #         when @index <= 15 then 'small'
    #         when @index <= 20 then 'tiny'
    #         when @index <= 25 then 'tiny'
    #     return buttonClass

    cloud_tag_class: ->
        buttonClass = switch
            when @index <= 10 then 'large'
            when @index <= 20 then ''
            when @index <= 30 then 'small'
            when @index <= 40 then 'tiny'
            when @index <= 50 then 'tiny'
        return buttonClass


    selected_tags: -> selected_tags.list()

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

Template.cloud.events
    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_tags.pop()
                    
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_tags.push doc.name
        $('#search').val ''
        
    'click .selectTag': -> selected_tags.push @name

    'click .unselectTag': -> selected_tags.remove @valueOf()

    'click #clearTags': -> selected_tags.clear()

Template.person.onCreated ->
    # console.log Template.currentData()
    @autorun -> Meteor.subscribe('review_doc', Template.currentData()._id)

Template.person.helpers
    tag_class: -> if @valueOf() in selected_tags.array() then 'blue' else ''
    
    cloud_tag_class: -> if @name in selected_tags.array() then 'blue' else ''
    
    top_cloud: -> @cloud
    
    review_tags: -> 
        # console.log @
        review_doc = Docs.findOne(author_id: Meteor.userId(), recipient_id: @_id)
        # console.log review_doc
        review_doc?.tags
    
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

    like_button_class: -> if @_id in Meteor.user().people_you_like then 'primary' else 'basic' 

    
Template.person.events
    'keydown .review_user': (e,t)->
        e.preventDefault
        tag = t.$('.review_user').val().toLowerCase().trim()
        if e.which is 13
            if tag.length > 0
                Meteor.call 'tag_user', Template.parentData(0)._id, tag, ->
                    $('.review_user').val('')

    'click .user_tag': -> if @name in selected_tags.array() then selected_tags.remove(@name) else selected_tags.push(@name)

    'click .add_liked_person': ->
        # console.log @_id
        Meteor.call 'add_liked_person', @_id

    'click .review_tag': (e,t)->
        tag = @valueOf()
        # console.log Template.currentData()._id
        Meteor.call 'remove_tag', Template.currentData()._id, tag, ->
            t.$('.review_user').val(tag)

    'autocompleteselect .review_user': (event, template, doc) ->
        # console.log 'selected ', doc
        Meteor.call 'tag_user', Template.parentData(0)._id, doc.name, ->
            $('.review_user').val ''



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
            
    cloud_tag_class: -> if @name in selected_tags.array() then 'blue' else ''
    match_tag_class: -> if @valueOf() in selected_tags.array() then 'blue' else ''


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

    'click .user_tag': -> if @name in selected_tags.array() then selected_tags.remove(@name) else selected_tags.push(@name)
    
    'click .match_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())


Template.people_you_like.onCreated ->
    @autorun -> Meteor.subscribe('people_you_like')

Template.people_you_like.helpers
    people_you_like: -> 
        if Meteor.user().people_you_like
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
    
