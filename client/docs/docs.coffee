@selected_doc_tags = new ReactiveArray []



Template.docs.onCreated ->
    @autorun -> Meteor.subscribe('docs', selected_doc_tags.array())
    @autorun -> Meteor.subscribe('doc_tags', selected_doc_tags.array())


Template.docs.helpers
    docs: -> 
        # Docs.find({ _id: $ne: Meteor.userId() })
        Docs.find({ }, limit: 3)

    tag_class: -> if @valueOf() in selected_doc_tags.array() then 'primary' else ''


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
        
    'click .selectTag': -> selected_doc_tags.push @name

    'click .unselectTag': -> selected_doc_tags.remove @valueOf()

    'click #clearTags': -> selected_doc_tags.clear()

Template.doc.onCreated ->
    # console.log Template.currentData()
    @autorun -> Meteor.subscribe('review_doc', Template.currentData()._id)

Template.doc.helpers
    doc_tag_class: -> if @valueOf() in selected_doc_tags.array() then 'blue' else ''
    
    # doc_tag_class: -> if @name in selected_doc_tags.array() then 'blue' else ''
    
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled basic'
        # else if Meteor.user().points < 1 then 'disabled basic'
        else if Meteor.userId() in @up_voters then 'green'
        else 'basic'

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled basic'
        # else if Meteor.user().points < 1 then 'disabled basic'
        else if Meteor.userId() in @down_voters then 'red'
        else 'basic'

    
    
    review_tags: -> 
        # console.log @
        review_doc = Docs.findOne(author_id: Meteor.userId(), recipient_id: @_id)
        # console.log review_doc
        review_doc?.tags
    
    is_author: -> Meteor.userId() is @author_id
    
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

    like_button_class: -> if @_id in Meteor.user().docs_you_like then 'primary' else 'basic' 

    


Template.doc.events
    'click .doc_tag': -> if @valueOf() in selected_doc_tags.array() then selected_doc_tags.remove(@valueOf()) else selected_doc_tags.push(@valueOf())

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

    'click .edit_doc': ->
        FlowRouter.go "/docs/edit/#{@_id}"
        
    'click .vote_down': -> Meteor.call 'vote_down', @_id

    'click .vote_up': -> Meteor.call 'vote_up', @_id
