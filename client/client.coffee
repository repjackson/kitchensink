@selected_tags = new ReactiveArray []


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    # dropdownClasses: 'simple'


Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'docs', selected_tags.array()

Template.docs.helpers
    docs: -> Docs.find {},
        limit: 1
        sort:
            tag_count: 1
            points: -1
            timestamp: 1
    # docs: -> Docs.find()
    
Template.layout.helpers
    is_editing: -> Session.get 'editing'


# Template.view.onCreated ->
    # console.log @data.authorId
    # Meteor.subscribe 'person', @data.authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()
    
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

    cloud_label_class: -> if @name in selected_tags.array() then 'primary' else ''
    
Template.view.events
    'click .edit_doc': -> Session.set 'editing', @_id

    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()

    'click .delete_doc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .delete': -> Meteor.call 'delete_doc', @_id


Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_tags.array()
    @autorun -> Meteor.subscribe 'me'


Template.cloud.helpers
    globalTags: ->
        # docCount = Docs.find().count()
        # if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find({}, limit: 20 )
        Tags.find({}, limit: 10)

    # cloud_tag_class: ->
    #     buttonClass = switch
    #         when @index <= 5 then ''
    #         when @index <= 10 then ''
    #         when @index <= 15 then 'small'
    #         when @index <= 20 then 'tiny'
    #         when @index <= 25 then 'tiny'
    #     return buttonClass

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
    'click #add_doc': ->
        Meteor.call 'create_doc', (err, id)->
            if err then console.log err
            else Session.set 'editing', id

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
    
    'keyup #add': (e,t)->
        e.preventDefault
        tag = $('#add').val().toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    splitTags = tag.match(/\S+/g);
                    $('#add').val('')
                    Meteor.call 'create_doc', splitTags
                    selected_tags.clear()
                    for tag in splitTags
                        selected_tags.push tag


Template.matches.helpers
    user_matches: ->
        # User_matches.find()
        # find all users with selected tag in tag_list
        users = Meteor.users.find( tag_list: $all: selected_tags.array()).fetch()
        user_matches = []
        for user in users
            tag_intersection = _.intersection(user.tag_list, Meteor.user().tag_list)
            user_matches.push
                matched_user: user.username
                tag_intersection: tag_intersection
                length: tag_intersection.length
        sorted_list = _.sortBy(user_matches, 'length').reverse()
        console.dir sorted_list
        return sorted_list
        
    other_people: -> Meteor.users.find()

Template.matches.onCreated ->
    self = @
    self.autorun ->
        # self.subscribe 'user_matches', selected_tags.array()
        self.subscribe 'everyone'


Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', Session.get 'editing'



Template.edit.helpers
    doc: -> Docs.findOne Session.get('editing')

Template.edit.events
    'keydown #addTag': (e,t)->
        e.preventDefault
        doc_id = Session.get('editing')
        tag = $('#addTag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update doc_id,
                        $addToSet: tags: tag
                    $('#addTag').val('')
                else
                    # body = $('#body').val()
                    Docs.update doc_id,
                        $set:
                            # body: body
                            tag_count: @tags.length
                            username: Meteor.user().username
                    selected_tags.clear()
                    selected_tags.push(tag) for tag in @tags
                    Session.set 'editing', null
            when 37
                if tag.length is 0
                    last = @tags.pop()
                    Docs.update doc_id,
                        $pop: tags:1
                    $('#addTag').val(last)


    'click .docTag': ->
        tag = @valueOf()
        Docs.update Session.get('editing'),
            $pull: tags: tag
        $('#addTag').val(tag)

    'click #saveDoc': ->
        # body = $('#body').val()
        Docs.update Session.get('editing'),
            $set:
                # body: body
                tag_count: @tags.length
                username: Meteor.user().username
        selected_tags.clear()
        for tag in @tags
            selected_tags.push tag
        Session.set 'editing', null