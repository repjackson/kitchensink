@selected_people_tags = new ReactiveArray []



Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selected_people_tags.array())
    @autorun -> Meteor.subscribe('people_tags', selected_people_tags.array())


Template.people.helpers
    people: -> 
        Meteor.users.find({ _id: $ne: Meteor.userId() })
        # Meteor.users.find({ })

    tag_class: -> if @valueOf() in selected_people_tags.array() then 'primary' else ''


Template.people_cloud.helpers
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


    selected_people_tags: -> selected_people_tags.list()

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

Template.people_cloud.events
    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_people_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_people_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_people_tags.pop()
                    
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_people_tags.push doc.name
        $('#search').val ''
        
    'click .selectTag': -> selected_people_tags.push @name

    'click .unselectTag': -> selected_people_tags.remove @valueOf()

    'click #clearTags': -> selected_people_tags.clear()

Template.person.onCreated ->
    # console.log Template.currentData()
    @autorun -> Meteor.subscribe('review_doc', Template.currentData()._id)

Template.person.helpers
    tag_class: -> if @valueOf() in selected_people_tags.array() then 'blue' else ''
    
    cloud_tag_class: -> if @name in selected_people_tags.array() then 'blue' else ''
    
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

    'click .user_tag': -> if @name in selected_people_tags.array() then selected_people_tags.remove(@name) else selected_people_tags.push(@name)

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

