Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('docId')


Template.edit.onRendered ->
    Meteor.setTimeout (->
        $('#body').froalaEditor
            height: 400
            toolbarButtonsXS: ['bold', 'italic', 'fontFamily', 'fontSize', 'undo', 'redo', 'insertImage']

        # $('#datetimepicker').datetimepicker(
        #     onChangeDateTime: (dp,$input)->
        #         val = $input.val()

        #         # console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
        #         minute = moment(val).minute()
        #         hour = moment(val).format('h')
        #         date = moment(val).format('Do')
        #         ampm = moment(val).format('a')
        #         weekdaynum = moment(val).isoWeekday()
        #         weekday = moment().isoWeekday(weekdaynum).format('dddd')

        #         month = moment(val).format('MMMM')
        #         year = moment(val).format('YYYY')

        #         datearray = [hour, minute, ampm, weekday, month, date, year]
        #         datearray = _.map(datearray, (el)-> el.toString().toLowerCase())
        #         # datearray = _.each(datearray, (el)-> console.log(typeof el))

        #         docid = FlowRouter.getParam 'docId'

        #         doc = Docs.findOne docid
        #         tagsWithoutDate = _.difference(doc.tags, doc.datearray)
        #         tagsWithNew = _.union(tagsWithoutDate, datearray)

        #         Docs.update docid,
        #             $set:
        #                 tags: tagsWithNew
        #                 datearray: datearray
        #                 dateTime: val
        #     )
        ), 500


Template.edit.helpers
    doc: ->
        docId = FlowRouter.getParam('docId')
        Docs.findOne docId



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