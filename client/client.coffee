@selected_tags = new ReactiveArray []


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    # dropdownClasses: 'simple'


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
        if user_count < 3 then Tags.find({ count: $lt: user_count }, limit: 20 ) else Tags.find({}, limit: 20 )
        # Tags.find({}, limit: 25)

    cloud_tag_class: ->
        buttonClass = switch
            when @index <= 5 then ''
            when @index <= 10 then ''
            when @index <= 15 then 'small'
            when @index <= 20 then 'tiny'
            when @index <= 25 then 'tiny'
        return buttonClass

    # cloud_tag_class: ->
    #     buttonClass = switch
    #         when @index <= 10 then 'large'
    #         when @index <= 20 then ''
    #         when @index <= 30 then 'small'
    #         when @index <= 40 then 'tiny'
    #         when @index <= 50 then 'tiny'
    #     return buttonClass


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
    tag_class: -> if @valueOf() in selected_tags.array() then 'blue' else 'basic'
    
    cloud_tag_class: -> if @name in selected_tags.array() then 'blue' else 'basic'
    
    review_tags: -> 
        # console.log @
        review_doc = Docs.findOne(author_id: Meteor.userId(), recipient_id: @_id)
        # console.log review_doc
        review_doc?.tags
    
    
Template.person.events
    'keydown .review_user': (e,t)->
        e.preventDefault
        tag = t.$('.review_user').val().toLowerCase().trim()
        if e.which is 13
            if tag.length > 0
                Meteor.call 'tag_user', @_id, tag, ->
                    $('.review_user').val('')






Template.profile.onCreated ->
    @autorun -> Meteor.subscribe('self_doc')
    
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

Template.profile.events
    'keydown #add_tag': (e,t)->
        e.preventDefault
        tag = $('#add_tag').val().toLowerCase().trim()
        if e.which is 13
            if tag.length > 0
                Meteor.call 'tag_user', Meteor.userId(), tag, ->
                    $('#add_tag').val('')

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
                        unless err 
                            alert "Updated contact to #{contact}."

    'click .my_tag': ->
        tag = @valueOf()
        Meteor.call 'remove_tag', Meteor.userId(), tag, ->
            $('#add_tag').val(tag)

    'autocompleteselect #add_tag': (event, template, doc) ->
        # console.log 'selected ', doc
        Meteor.call 'add_tag', doc.name, ->
            $('#add_tag').val ''
