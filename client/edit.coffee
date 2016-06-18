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
    
    unpicked_alchemy_tags: -> _.difference @alchemy_tags, @tags
    unpicked_yaki_tags: -> _.difference @yaki_tags, @tags

    

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
        
        
    'click #alchemy_suggest': ->
        Docs.update Session.get('editing'),
            $set: body: $('#body').val()
        Meteor.call 'alchemy_suggest', Session.get('editing')

    'click #yaki_suggest': ->
        Docs.update Session.get('editing'),
            $set: body: $('#body').val()
        Meteor.call 'yaki_suggest', Session.get('editing')


    'click .add_alchemy_suggestion': ->
        docId = Session.get('editing')
        Docs.update docId, $addToSet: tags: @valueOf()

    'click .add_yaki_suggestion': ->
        docId = Session.get('editing')
        Docs.update docId, $addToSet: tags: @valueOf()

    'click #add_all_alchemy': ->
        docId = Session.get('editing')
        Docs.update docId,
            $addToSet: tags: $each: @alchemy_tags

    'click #add_all_yaki': ->
        docId = Session.get('editing')
        Docs.update docId,
            $addToSet: tags: $each: @yaki_tags

