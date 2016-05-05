Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('docId')


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#body').froalaEditor
            height: 400
            toolbarButtonsXS: ['bold', 'italic', 'fontFamily', 'fontSize', 'undo', 'redo', 'insertImage']

        ), 300


Template.edit.helpers
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId

    unique_suggested_tags: -> _.difference(@suggested_tags, @tags)


Template.edit.events
    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deleteDoc', FlowRouter.getParam('docId'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/docs'
        	).modal 'show'


    'keydown #addTag': (e,t)->
        e.preventDefault
        tag = $('#addTag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update FlowRouter.getParam('docId'),
                        $addToSet: tags: tag
                    $('#addTag').val('')
                else
                    body = $('#body').val()
                    Docs.update FlowRouter.getParam('docId'),
                        $set:
                            body: body
                            tagCount: @tags.length
                    selectedTags.clear()
                    for tag in @tags
                        selectedTags.push tag
                    FlowRouter.go '/'

    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $pull: tags: tag
        $('#addTag').val(tag)


    'click #saveDoc': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('docId'),
            $set:
                body: body
                tagCount: @tags.length
        selectedTags.clear()
        for tag in @tags
            selectedTags.push tag
        FlowRouter.go '/'


    'click #deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id, (err, result)->
                if err then console.error err
                else
                    FlowRouter.go '/'

    'click #suggest_tags': ->
        body = $('#body').val()
        Meteor.call 'suggest_tags', @_id, body


    'click .add_suggested_tag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('docId'),
            $addToSet: tags: tag
            , ->

    'click #add_all_suggested_tags': ->
        Docs.update FlowRouter.getParam('docId'), $addToSet: tags: $each: @suggested_tags

    'click #clear_doc_tags': ->
        Docs.update FlowRouter.getParam('docId'), $set: tags: []

    'click #clear_suggested_tags': ->
        Docs.update FlowRouter.getParam('docId'), $set: suggested_tags: []
