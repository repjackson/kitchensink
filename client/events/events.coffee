Template.events.onCreated ->
    @autorun -> Meteor.subscribe('events', selectedEventTags.array())

Template.events.helpers
    events: -> Events.find()


# Single
Template.event.onCreated ->
    @autorun -> Meteor.subscribe('eventMessages', Template.currentData()._id)
    @autorun -> Meteor.subscribe('usernames')

Template.event.helpers
    tagClass: ->
        if @valueOf() in selectedEventTags.array() then 'secondary' else 'basic'

    attending: -> if Meteor.userId() in @attendeeIds then true else false

    isHost: -> @hostId is Meteor.userId()

    eventMessages: -> Messages.find eventId: @_id

Template.event.onRendered ->
    data = Template.currentData()

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


                event = Events.findOne data._id
                tagsWithoutDate = _.difference(event.tags, event.datearray)
                tagsWithNew = _.union(tagsWithoutDate, datearray)

                Events.update data._id,
                    $set:
                        tags: tagsWithNew
                        datearray: datearray
                        dateTime: val
            )
        ), 500


Template.event.events
    'click .tag': ->
        if @valueOf() in selectedEventTags.array() then selectedEventTags.remove @valueOf() else selectedEventTags.push @valueOf()

    'click .join_event': ->
        Meteor.call 'join_event', @_id

    'click .leave_event': ->
        Meteor.call 'leave_event', @_id

    'click .clearDT': ->
        tagsWithoutDate = _.difference(@tags, @datearray)
        Events.update @_id,
            $set:
                tags: tagsWithoutDate
                datearray: []
                dateTime: null
        $('#datetimepicker').val('')


    'keydown .addMessage': (e,t)->
        e.preventDefault
        switch e.which
            when 13
                text = t.find('.addMessage').value.trim()
                if text.length > 0
                    Meteor.call 'add_event_message', text, @_id, (err,res)->
                        t.find('.addMessage').value = ''

    'click .cancelEvent': ->
        if confirm 'Cancel event?'
            Events.remove @_id