Template.doc_cloud.onCreated ->
    # @autorun -> Meteor.subscribe 'doc_tags', selected_doc_tags.array(), Session.get('selected_user'), Session.get('upvoted_cloud'), Session.get('downvoted_cloud'), Session.get('unvoted')
    @autorun -> Meteor.subscribe 'doc_tags', selected_doc_tags.array(), selected_authors.array(), Session.get('upvoted_cloud'), Session.get('downvoted_cloud'), Session.get('unvoted')
    @autorun -> Meteor.subscribe('authors', selected_doc_tags.array(), selected_authors.array(), Session.get('view'))
    @autorun -> Meteor.subscribe('people', selected_doc_tags.array())



Template.doc_cloud.helpers
    all_doc_tags: ->
        doc_count = Docs.find().count()
        # console.log doc_count
        # if doc_count < 3 then Tags.find({ count: $lt: doc_count }, limit: 20 ) else Tags.find({}, limit: 20 )
        if doc_count < 3 then Tags.find({ count: $lt: doc_count }, limit: 50 ) else Tags.find({}, limit: 50 )
        # Tags.find({}, limit: 20)

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

    selected_user: -> if Session.get 'selected_user' then Meteor.users.findOne(Session.get('selected_user'))?.username

    upvoted_cloud: -> if Session.get 'upvoted_cloud' then Meteor.users.findOne(Session.get('upvoted_cloud'))?.username

    downvoted_cloud: -> if Session.get 'downvoted_cloud' then Meteor.users.findOne(Session.get('downvoted_cloud'))?.username

    all_authors: -> Authors.find()
    
    selected_authors: -> selected_authors.list()

    author_name: ->  Meteor.users.findOne(@author_id)?.username

    selected_author_name: -> 
        Meteor.users.findOne(@valueOf()).username

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

    'click #bookmark_selection': ->
        # if confirm 'Bookmark Selection?'
        Meteor.call 'add_bookmark', selected_doc_tags.array(), (err,res)->
            swal "Selection bookmarked"

    'click .selected_user_button': -> Session.set 'selected_user', null
    'click .upvoted_cloud_button': -> Session.set 'upvoted_cloud', null
    'click .downvoted_cloud_button': -> Session.set 'downvoted_cloud', null

    'click #mine': ->
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null
        # Session.set 'selected_user', Meteor.userId()
        selected_authors.clear()
        selected_authors.push Meteor.userId()

    'click #my_upvoted': ->
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', Meteor.userId()

    'click #my_downvoted': ->
        Session.set 'selected_user', null
        Session.set 'upvoted_cloud', null
        Session.set 'downvoted_cloud', Meteor.userId()

    'click #unvoted': ->
        if Session.equals('unvoted', true) then Session.set('unvoted', false) else Session.set('unvoted', true)


    'click .select_author': -> selected_authors.push @author_id
    'click .unselect_author': -> selected_authors.remove @valueOf()
    'click #clear_authors': -> selected_authors.clear()

