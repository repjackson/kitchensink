Template.edit_description.events
    'blur .froala-container': (e,t)->
        html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
        
        # snippet = $('#snippet').val()
        # if snippet.length is 0
        #     snippet = $(html).text().substr(0, 300).concat('...')
        doc_id = FlowRouter.getParam('doc_id')

        Docs.update doc_id,
            $set: 
                description: html
                # snippet: snippet

    # 'blur #snippet': (e,t)->
    #     text = $('#snippet').val()
    #     doc_id = FlowRouter.getParam('doc_id')

    #     Docs.update doc_id,
    #         $set: 
    #             snippet: text


    'click #upload_widget_opener': (e,t)->
        cloudinary.openUploadWidget {
            cloud_name: 'facet'
            upload_preset: 'rodonu5a'
        }, (error, result) ->
            # console.log error, result
            Docs.update FlowRouter.getParam('doc_id'),
                $addToSet: image_array: $each: result




Template.edit_description.helpers
    getFEContext: ->
        @current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        self = @
        {
            _value: self.current_doc.description
            _keepMarkers: true
            _className: 'froala-reactive-meteorized-override'
            toolbarInline: false
            initOnClick: false
            imageInsertButtons: ['imageBack', '|', 'imageByURL']
            tabSpaces: false
            height: 300
            '_onsave.before': (e, editor) ->
                # Get edited HTML from Froala-Editor
                newHTML = editor.html.get(true)
                # Do something to update the edited value provided by the Froala-Editor plugin, if it has changed:
                if !_.isEqual(newHTML, self.current_doc.description)
                    # console.log 'onSave HTML is :' + newHTML
                    Docs.update { _id: self.current_doc._id }, $set: description: newHTML
                false
                # Stop Froala Editor from POSTing to the Save URL
        }
