@selected_tags = new ReactiveArray []


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    dropdownClasses: 'simple'


Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'docs', selected_tags.array()

Template.docs.helpers
    docs: -> Docs.find {},
        limit: 3
        sort:
            tag_count: 1
            points: -1
    # docs: -> Docs.find()
    
Template.layout.helpers
    is_editing: -> Session.get 'editing'


Template.view.onCreated ->
    # console.log @data.authorId
    # Meteor.subscribe 'person', @data.authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()
    
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

    cloud_label_class: -> if @name in selected_tags.array() then 'primary' else ''
    
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled'
        # else if Meteor.user().points < 1 then 'disabled basic'
        else if Meteor.userId() in @up_voters then 'green'
        else 'basic'

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled basic'
        # else if Meteor.user().points < 1 then 'disabled basic'
        else if Meteor.userId() in @down_voters then 'red'
        else 'basic'


Template.view.events
    'click .edit_doc': -> Session.set 'editing', @_id

    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()

    'click .delete_doc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .vote_down': -> Meteor.call 'vote_down', @_id

    'click .vote_up': -> Meteor.call 'vote_up', @_id



Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_tags.array()
    @autorun -> Meteor.subscribe 'me'


Template.cloud.helpers
    globalTags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        # Tags.find()


    # globalTagClass: ->
    #     buttonClass = switch
    #         when @index <= 5 then 'big'
    #         when @index <= 10 then 'large'
    #         when @index <= 15 then ''
    #         when @index <= 20 then 'small'
    #         when @index <= 25 then 'tiny'
    #     return buttonClass


    selected_tags: -> selected_tags.list()


Template.cloud.events
    'click #add_doc': ->
        Meteor.call 'create_doc', selected_tags.array(), (err, id)->
            if err then console.log err
            else Session.set 'editing', id

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val()
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

    'click .selectTag': -> selected_tags.push @name

    'click .unselectTag': -> selected_tags.remove @valueOf()

    'click #clearTags': -> selected_tags.clear()


Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', Session.get 'editing'


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#body').froalaEditor
            heightMin: 200
            # toolbarButtons: ['bold', 'italic', 'fontSize', 'undo', 'redo', '|', 'insertImage', 'insertVideo','insertFile']
            # toolbarButtonsMD: ['bold', 'italic', 'fontSize', 'undo', 'redo', '|', 'insertImage', 'insertVideo','insertFile']
            # toolbarButtonsSM: ['bold', 'italic', 'fontSize', 'undo', 'redo', '|', 'insertImage', 'insertVideo','insertFile']
            # toolbarButtonsXS: ['bold', 'italic', 'fontSize', 'undo', 'redo', '|', 'insertImage', 'insertVideo','insertFile']

        ), 200


Template.edit.helpers
    doc: -> Docs.findOne Session.get('editing')
    unpicked_alchemy_tags: -> _.difference @alchemy_tags, @tags


Template.edit.events
    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deleteDoc', Session.get('editing'), ->
                $('.ui.modal').modal('hide')
                Session.set 'editing', null
        	).modal 'show'

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
                    body = $('#body').val()
                    Docs.update doc_id,
                        $set:
                            body: body
                            tag_count: @tags.length
                            username: Meteor.user().username
                    selected_tags.clear()
                    selected_tags.push(tag) for tag in @tags
                    Session.set 'editing', null


    'click .docTag': ->
        tag = @valueOf()
        Docs.update Session.get('editing'),
            $pull: tags: tag
        $('#addTag').val(tag)



    'click #saveDoc': ->
        body = $('#body').val()
        Docs.update Session.get('editing'),
            $set:
                body: body
                tag_count: @tags.length
                username: Meteor.user().username
        selected_tags.clear()
        for tag in @tags
            selected_tags.push tag
        Session.set 'editing', null

    'click #alchemy_suggest': ->
        body = $('#body').val()
        Meteor.call 'alchemy_suggest', Session.get('editing'), body, (err,res)->
            if err then console.log err
            else console.log res
        Docs.update Session.get('editing'),
            $set: body: body

    'click .add_alchemy_suggestion': ->
        docId = Session.get('editing')
        Docs.update docId, $addToSet: tags: @valueOf()

    'click #add_all_alchemy': ->
        docId = Session.get('editing')
        Docs.update docId,
            $addToSet: tags: $each: @alchemy_tags