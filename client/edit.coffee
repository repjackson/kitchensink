Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', Session.get 'editing'


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#body').froalaEditor
            height: 400
            toolbarButtonsXS: ['bold', 'italic', 'fontFamily', 'fontSize', 'undo', 'redo', 'insertImage']

        ), 300


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
        tag = $('#addTag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update Session.get('editing'),
                        $addToSet: tags: tag
                    $('#addTag').val('')

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
                tagCount: @tags.length
        selected_tags.clear()
        for tag in @tags
            selected_tags.push tag
        Session.set 'editing', null