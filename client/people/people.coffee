@selected_tags = new ReactiveArray []



Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selected_tags.array())
    @autorun -> Meteor.subscribe('tags', selected_tags.array())


Template.people.helpers
    people: -> 
        # Meteor.users.find({ _id: $ne: Meteor.userId() })
        Meteor.users.find({ })

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''


Template.cloud.helpers
    all_tags: ->
        # user_count = Meteor.users.find().count()
        # # console.log user_count
        # if user_count < 3 then Tags.find({ count: $lt: user_count }, limit: 20 ) else Tags.find({}, limit: 50 )
        Tags.find({}, limit: 25)

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
        
    'click .select_tag': -> selected_tags.push @name

    'click .unselect_tag': -> selected_tags.remove @valueOf()

    'click #clear_tags': -> selected_tags.clear()

Template.person.onCreated ->
    # console.log Template.currentData()
    # @autorun -> Meteor.subscribe('person', Template.currentData()._id)

Template.person.helpers
    person_tag_class: -> if @valueOf() in selected_tags.array() then 'blue' else ''
    
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
    


Template.person.events
    'click .person_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())
