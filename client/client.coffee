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
    people: -> Meteor.users.find({ _id: $ne: Meteor.userId() })

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''


Template.cloud.helpers
    globalTags: ->
        # docCount = Docs.find().count()
        # if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find({}, limit: 20 )
        Tags.find({})

    # cloud_tag_class: ->
    #     buttonClass = switch
    #         when @index <= 5 then ''
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
                    
    'autocompleteselect input': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_tags.push doc.name
        $('#search').val ''
        
    'click .selectTag': -> selected_tags.push @name

    'click .unselectTag': -> selected_tags.remove @valueOf()

    'click #clearTags': -> selected_tags.clear()
    