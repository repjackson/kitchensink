Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')


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
    Meteor.setTimeout (->
        $('#datetimepicker').datetimepicker(
            onChangeDateTime: (dp,$input)->
                val = $input.val()

                # console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
                minute = moment(val).minute()
                hour = moment(val).format('h')
                date = moment(val).format('Do')
                ampm = moment(val).format('a')
                weekdaynum = moment(val).isoWeekday()
                weekday = moment().isoWeekday(weekdaynum).format('dddd')

                month = moment(val).format('MMMM')
                year = moment(val).format('YYYY')

                datearray = [hour, minute, ampm, weekday, month, date, year]
                datearray = _.map(datearray, (el)-> el.toString().toLowerCase())
                # datearray = _.each(datearray, (el)-> console.log(typeof el))

                doc_id = FlowRouter.getParam 'doc_id'

                doc = Docs.findOne doc_id
                tags_without_date = _.difference(doc.tags, doc.datearray)
                tagsWithNew = _.union(tags_without_date, datearray)

                Docs.update doc_id,
                    $set:
                        tags: tagsWithNew
                        datearray: datearray
                        dateTime: val
            )
        ), 500
    
    @autorun ->
        if GoogleMaps.loaded()
            $('#place').geocomplete().bind 'geocode:result', (event, result) ->
                # console.log result.geometry.location.lat()
                Meteor.call 'updatelocation', doc_id, result, ->



Template.edit.helpers
    unpicked_alchemy_tags: -> _.difference @alchemy_tags, @tags
    unpickedConcepts: -> _.difference @concept_array, @tags

    unpicked_yaki_tags: -> _.difference @yaki_tags, @tags

    doc: -> Docs.findOne FlowRouter.getParam('doc_id')


Template.edit.events
    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deleteDoc', FlowRouter.getParam('doc_id'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/docs'
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
                else
                    body = $('#body').val()
                    Docs.update doc_id,
                        $set:
                            body: body
                            tag_count: @tags.length
                            username: Meteor.user().username
                    selected_doc_tags.clear()
                    selected_doc_tags.push(tag) for tag in @tags
                    FlowRouter.go '/docs'
            when 37
                if tag.length is 0
                    last = @tags.pop()
                    Docs.update doc_id,
                        $pop: tags:1
                    $('#add_tag').val(last)


    'click .docTag': ->
        tag = @valueOf()
        Docs.update FlowRouter.getParam('doc_id'),
            $pull: tags: tag
        $('#add_tag').val(tag)

    'click #alchemy_suggest': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: body: body
        Meteor.call 'alchemy_suggest', FlowRouter.getParam('doc_id'), body

    'click #yaki_suggest': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: body: body
        Meteor.call 'yaki_suggest', FlowRouter.getParam('doc_id'), body


    'click .add_alchemy_suggestion': ->
        doc_id = FlowRouter.getParam('doc_id')
        Docs.update doc_id, $addToSet: tags: @valueOf()

    'click .add_yaki_suggestion': ->
        doc_id = FlowRouter.getParam('doc_id')
        Docs.update doc_id, $addToSet: tags: @valueOf()

    'click #add_all_alchemy': ->
        doc_id = FlowRouter.getParam('doc_id')
        Docs.update doc_id,
            $addToSet: tags: $each: @alchemy_tags

    'click #add_all_yaki': ->
        doc_id = FlowRouter.getParam('doc_id')
        Docs.update doc_id,
            $addToSet: tags: $each: @yaki_tags

    'click #save_doc': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                body: body
                tag_count: @tags.length
                username: Meteor.user().username
        selected_doc_tags.clear()
        for tag in @tags
            selected_doc_tags.push tag
            FlowRouter.go '/docs'
            
            
    'click .clear_date': ->
        tags_without_date = _.difference(@tags, @datearray)
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                tags: tags_without_date
                datearray: []
                dateTime: null
        $('#datepicker').val('')

    'click .clear_address': ->
        tags_without_address = _.difference(@tags, @addresstags)
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                tags: tags_without_address
                addresstags: []
                locationob: null
        $('#place').val('')


    'keyup #url': (e,t)->
        doc_id = FlowRouter.getParam('doc_id')
        url = $('#url').val()
        switch e.which
            when 13
                if url.length > 0
                    Docs.update doc_id,
                        $set: url: url
                    Meteor.call 'fetch_url_tags', doc_id, url
