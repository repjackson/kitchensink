Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')


Template.edit.helpers
    doc: -> Docs.findOne FlowRouter.getParam('doc_id')

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
        ), 500
    




Template.edit.events
    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'delete', FlowRouter.getParam('doc_id'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/'
                ).modal 'show'

    'keydown #add_tag': (e,t)->
        e.preventDefault
        doc_id = FlowRouter.getParam('doc_id')
        tag = $('#add_tag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Docs.update doc_id,
                        $addToSet: tags: tag
                    $('#add_tag').val('')
            #     else
            #         body = $('#body').val()
            #         Docs.update doc_id,
            #             $set:
            #                 body: body
            #                 tag_count: @tags.length
            #                 username: Meteor.user().username
            #         selected_tags.clear()
            #         selected_tags.push(tag) for tag in @tags
            #         FlowRouter.go '/docs'
            # when 37
            #     if tag.length is 0
            #         last = @tags.pop()
            #         Docs.update doc_id,
            #             $pop: tags:1
            #         $('#add_tag').val(last)


    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('doc_id'),
            $pull: tags: tag
        $('#add_tag').val(tag)

    'click #save_doc': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                body: body
                tag_count: @tags.length
                username: Meteor.user().username
        selected_tags.clear()
        for tag in @tags
            selected_tags.push tag
            FlowRouter.go '/'
            