Accounts.ui.config
    # requestOfflineToken: google: true
    passwordSignupFields: 'USERNAME_ONLY'


Template.cloud.helpers
    all_tags: ->
        user_count = Meteor.users.find(_id: $ne: Meteor.userId() ).count()
        # console.log user_count
        if user_count < 3 then Tags.find({ count: $lt: user_count }, limit: 20 ) else Tags.find({}, limit: 20 )
        # Tags.find({}, limit: 25)

    location_tags: -> Location_tags.find()
    
    active_locations: -> Active_locations.find()
    
    active_location_tag_class: -> if Session.equals('active_location', @name) then 'primary' else ''

    is_self_tagged: -> @valueOf() in Meteor.user().tags
    
    
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
    
    'click .active_location_tag': -> 
        if Session.equals('active_location', @name) then Session.set('active_location', null) else Session.set('active_location', @name)
        # Session.set('active_location')
        
    'click .add_cloud_tag': -> 
        tag = @valueOf()
        Meteor.call 'add_tag', tag, (err, res)->
            if err then console.error err
            else
                swal 
                    title:"#{tag} added to your tags"
                    timer: 1000
                    animation: false
                    showConfirmButton: false
    
    'click .remove_cloud_tag': -> 
        tag = @valueOf()
        Meteor.call 'remove_tag', tag, (err, res)->
            if err then console.error err
            else
                swal 
                    title: "#{tag} removed from your tags"
                    timer: 1000
                    animation: false
                    showConfirmButton: false