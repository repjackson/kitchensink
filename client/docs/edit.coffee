Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('docId')


Template.edit.onRendered ->
    docId = FlowRouter.getParam('docId')
    Meteor.setTimeout (->
        $('#body').froalaEditor
            height: 400
            toolbarButtonsXS: ['bold', 'italic', 'fontFamily', 'fontSize', 'undo', 'redo', 'insertImage']

        ), 300

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

                docid = FlowRouter.getParam 'docId'

                doc = Docs.findOne docid
                tagsWithoutDate = _.difference(doc.tags, doc.datearray)
                tagsWithNew = _.union(tagsWithoutDate, datearray)

                Docs.update docid,
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
                Meteor.call 'updatelocation', docId, result, ->



Template.edit.helpers
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId

    unpickedKeywords: ->
        _.difference @keyword_array, @tags

    unpicked_suggested_tags: ->
        _.difference @suggested_tags, @tags



Template.edit.events
    'click #delete': ->
        $('.modal').modal(
            onApprove: ->
                Meteor.call 'deleteDoc', FlowRouter.getParam('docId'), ->
                $('.ui.modal').modal('hide')
                FlowRouter.go '/docs'
        	).modal 'show'

    'click .clearDT': ->
        tagsWithoutDate = _.difference(@tags, @datearray)
        Docs.update FlowRouter.getParam('docId'),
            $set:
                tags: tagsWithoutDate
                datearray: []
                dateTime: null
        $('#datetimepicker').val('')

    'click .clearAddress': ->
        tagsWithoutAddress = _.difference(@tags, @addresstags)
        Docs.update FlowRouter.getParam('docId'),
            $set:
                tags: tagsWithoutAddress
                addresstags: []
                locationob: null
        $('#place').val('')

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

    'keyup #url': (e,t)->
        docId = FlowRouter.getParam('docId')
        url = $('#url').val()
        switch e.which
            when 13
                if url.length > 0
                    Docs.update docId,
                        $set: url: url
                    Meteor.call 'fetchUrlTags', docId, url

    'click #analyzeBody': ->
        Docs.update FlowRouter.getParam('docId'),
            $set: body: $('#body').val()
        Meteor.call 'analyze', FlowRouter.getParam('docId')

    'click #suggest_tags': ->
        body = $('#body').val()
        Docs.update FlowRouter.getParam('docId'),
            $set: body: body
        Meteor.call 'suggest_tags', FlowRouter.getParam('docId'), body

    'click .docKeyword': ->
        docId = FlowRouter.getParam('docId')
        Docs.update docId, $addToSet: tags: @valueOf()

    'click #addAll': ->
        docId = FlowRouter.getParam('docId')
        Docs.update docId,
            $addToSet: tags: $each: @keyword_array
