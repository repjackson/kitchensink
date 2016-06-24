@selected_tags = new ReactiveArray []


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'
    dropdownClasses: 'simple'


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
        if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find({}, limit: 7 )
        # Tags.find()

    # cloud_tag_class: ->
    #     buttonClass = switch
    #         when @index <= 5 then ''
    #         when @index <= 10 then ''
    #         when @index <= 15 then 'small'
    #         when @index <= 20 then 'tiny'
    #         # when @index <= 25 then 'tiny'
    #     return buttonClass

    add_doc_button_class: ->
        if selected_tags.array().length > 0 then 'primary' else ''

    selected_tags: -> selected_tags.list()

    # if_is_bookmark: ->
    #     for bookmark in Meteor.user().bookmarks
    #         if selected_tags.array().length is bookmark.length
    #             if _.intersection(selected_tags.array(), bookmark).length is bookmark.length
    #                 return true
    #             else
    #                 return false

    # settings: ->
    #     {
    #         position: 'bottom'
    #         limit: 10
    #         rules: [
    #             {
    #                 # token: ''
    #                 collection: Tags
    #                 field: 'name'
    #                 matchAll: true
    #                 template: Template.tag_result
    #             }
    #         ]
    #     }

Template.cloud.events
    'click #add_doc': ->
        Meteor.call 'create_doc', selected_tags.array(), (err, id)->
            if err then console.log err
            else Session.set 'editing', id

    # 'keyup #search': (e,t)->
    #     e.preventDefault()
    #     val = $('#search').val()
    #     switch e.which
    #         when 13 #enter
    #             switch val
    #                 when 'clear'
    #                     selected_tags.clear()
    #                     $('#search').val ''
    #                 else
    #                     unless val.length is 0
    #                         selected_tags.push val.toString()
    #                         $('#search').val ''
    #         when 8
    #             if val.length is 0
    #                 selected_tags.pop()
                    
    # 'autocompleteselect input': (event, template, doc) ->
    #     # console.log 'selected ', doc
    #     selected_tags.push doc.name
    #     $('#search').val ''
        
    # 'click #bookmark_selection': ->
    #     # if confirm 'Bookmark Selection?'
    #     # if selected_tags.array() in Meteor.user().bookmarks then console.log 'true' else console.log 'false'
    #     Meteor.call 'add_bookmark', selected_tags.array(), (err,res)->
    #         alert "Selection bookmarked"

    # 'click .select_bookmark': ->
    #     selected_tags.clear()
    #     selected_tags.push tag for tag in @ 

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
            # toolbarInline: true
            # toolbarButtonsMD: ['bold', 'italic', 'fontSize', 'undo', 'redo', '|', 'insertImage', 'insertVideo','insertFile']
            # toolbarButtonsSM: ['bold', 'italic', 'fontSize', 'undo', 'redo', '|', 'insertImage', 'insertVideo','insertFile']
            # toolbarButtonsXS: ['bold', 'italic', 'fontSize', 'undo', 'redo', '|', 'insertImage', 'insertVideo','insertFile']
            toolbarButtons: 
                [
                  'fullscreen'
                  'bold'
                  'italic'
                  'underline'
                  'strikeThrough'
                  'subscript'
                  'superscript'
                #   'fontFamily'
                #   'fontSize'
                  '|'
                  'color'
                  'emoticons'
                #   'inlineStyle'
                #   'paragraphStyle'
                  '|'
                  'paragraphFormat'
                  'align'
                  'formatOL'
                  'formatUL'
                  'outdent'
                  'indent'
                  'quote'
                  'insertHR'
                  '-'
                  'insertLink'
                  'insertImage'
                  'insertVideo'
                  'insertFile'
                  'insertTable'
                  'undo'
                  'redo'
                  'clearFormatting'
                  'selectAll'
                  'html'
                ]
        ), 200


Template.edit.helpers
    doc: -> Docs.findOne Session.get('editing')

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