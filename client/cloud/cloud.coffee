Template.doc_cloud.helpers
    all_doc_tags: ->
        doc_count = Docs.find().count()
        # console.log doc_count
        if doc_count < 3 then Tags.find({ count: $lt: doc_count }, limit: 40 ) else Tags.find({}, limit: 40 )
        # Tags.find({})

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


    selected_doc_tags: -> selected_doc_tags.list()

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

Template.doc_cloud.events
    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_doc_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_doc_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_doc_tags.pop()
                    
    'keyup #quick_add': (e,t)->
        e.preventDefault
        tag = $('#quick_add').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    split_tags = tag.match(/\S+/g)
                    $('#quick_add').val('')
                    Meteor.call 'create_doc_with_tags', split_tags
                    selected_doc_tags.clear()
                    for tag in split_tags
                        selected_doc_tags.push tag
                    # FlowRouter.go '/'
                    
                    
                    
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_doc_tags.push doc.name
        $('#search').val ''
        
    'click #add_doc': -> 
        Meteor.call 'create_doc', (err, id)->
            FlowRouter.go "/docs/edit/#{id}"
        
    'click .select_tag': -> selected_doc_tags.push @name

    'click .unselect_tag': -> selected_doc_tags.remove @valueOf()

    'click #clear_tags': -> selected_doc_tags.clear()
