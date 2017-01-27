FlowRouter.route '/events', action: (params) ->
    BlazeLayout.render 'layout',
        # cloud: 'event_cloud'
        main: 'events'

FlowRouter.route '/event/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_event'

FlowRouter.route '/event/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        # main: 'event_page'
        main: 'event_page'





if Meteor.isClient
    Template.events.onRendered ->
        $('#event_slider').layerSlider
            autoStart: true
     
        
    Template.events.events
        'keydown #import_eventbrite': (e,t)->
            e.preventDefault
            if e.which is 13
                event_id = t.find('#import_eventbrite').value.trim()
                if event_id.length > 0
                    # console.log 'attemping to add event with id ', event_id
                    Meteor.call 'import_eventbrite', event_id, (err,res)->
                        t.find('#import_eventbrite').value = ''
                        console.log res
    
        'click #add_event': ->
            id = Docs.insert 
                type: 'event'
            FlowRouter.go "/event/edit/#{id}"
    
    
    
    
    Template.events.onCreated -> @autorun -> Meteor.subscribe('selected_events', selected_tags.array())
    # Template.admin_events.onCreated -> @autorun -> Meteor.subscribe('all_events')
    # Template.upcoming_events.onCreated -> @autorun -> Meteor.subscribe('upcoming_events', selected_tags.array())
    # Template.past_events.onCreated -> @autorun -> Meteor.subscribe('past_events', selected_tags.array())
    
    Template.upcoming_events.helpers
        upcoming_events: -> 
            today = new Date()
            today.setDate today.getDate() - 1
            # Docs.find {start_date: $gte: today.toISOString()}, sort: start_date: 1
            Docs.find { 
                type:'event'
                reoccurring: $ne: true
                published: $ne: false
                start_datetime: $gte: today.toISOString()
                }, 
                sort: start_datetime: 1
    
    Template.admin_events.helpers
        admin_events: -> 
            Docs.find { 
                published: false
                }
                
    Template.past_events.helpers
        past_events: -> 
            today = new Date()
            today.setDate today.getDate() - 1
            # Docs.find {start_date: $lte: today.toISOString()}, sort: start_date: 1
            Docs.find { 
                type:'event'
                reoccurring: $ne: true
                published: $ne: false
                start_datetime: $lte: today.toISOString()
                }, 
                sort: start_datetime: 1
                limit: 10
                
    Template.reoccurring_events.helpers
        reoccurring_events: -> 
            today = new Date()
            # Docs.find {start_date: $lte: today.toISOString()}, sort: start_date: 1
            Docs.find { 
                type:'event'
                reoccurring: true
                published: $ne: false
                # start_datetime: $gte: today.toISOString()
                }, 
                sort: start_datetime: 1
                
    
    Template.events.helpers
        options: ->
            # defaultView: 'basicWeek'
            defaultView: 'month'
    
    
    
    Template.event_card.helpers
        event_tag_class: -> if @valueOf() in selected_tags.array() then 'red' else 'basic'
    
        day: -> moment(@start_datetime).format("dddd, MMMM Do");
        start_time: -> moment(@start_datetime).format("h:mm a")
        end_time: -> moment(@end_datetime).format("h:mm a")
    
    
    Template.event_card.events
        # 'click .event_tag': ->
        #     if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()


if Meteor.isServer
    Meteor.publish 'featured_events', ->
        Docs.find  {       
            featured: true
            # tags: $in: ['academy']
            type: 'event'
            }, 
            sort: start_date: -1
    
    
    # Meteor.publish 'upcoming_events', (selected_event_tags)->
    
    #     self = @
    #     match = {}
    #     if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
    
    #     today = Date.now()
    #     # match.start.local = $gt: today
    #     match["start.local"] = $lte: today
    
    #     console.log 'upcoming events match', match
    #     Events.find match,
    #         limit: 10
    #         # sort: 
    #         #     start_date: 1
    
    Meteor.publish 'selected_events', (selected_event_tags)->
        
        self = @
        match = {}
        # selected_event_tags.push 'academy'
    
        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.type = 'event'
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
        Docs.find match
    
    
    # Meteor.publish 'past_events', (selected_event_tags)->
    
    #     self = @
    #     match = {}
    #     if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        
    #     Events.find match,
    #         limit: 10
    #         # sort: 
    #         #     start_date: 1
    
    
    Meteor.publish 'all_events', ->
        Docs.find type: 'event'
    
    Meteor.publish 'event_tags', (selected_event_tags)->
        self = @
        match = {}
        # selected_event_tags.push 'academy'
        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.type = 'event'
        
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true
        
    
    
        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_event_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
    
        cloud.forEach (tag, i) ->
            self.added 'event_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
    
    
    
    Meteor.methods
        import_eventbrite: (event_id)->
            HTTP.get "https://www.eventbriteapi.com/v3/events/#{event_id}", {
                    params:
                        token: 'QLL5EULOADTSJDS74HH7'
                        expand: 'organizer,venue,logo,format,category,subcategory,ticket_classes,bookmark_info'
                }, 
                (err, res)->
                    if err
                        console.error err
                    else
                        event = res.data
                        existing_event = Docs.findOne { id: event.id} 
                        if existing_event
                            console.log 'found duplicate', event.id
                            return
                        else
                            image_id = event.logo.id
                            image_object = HTTP.get "https://www.eventbriteapi.com/v3/media/#{image_id}", {
                                params:
                                    token: 'QLL5EULOADTSJDS74HH7'
                            }
                            # console.log image_object
                            # console.dir event
                            new_image_url = image_object.data.url
                            event.big_image_url = new_image_url
                            val = event.start.local
                            # console.log val
                            minute = moment(val).minute()
                            hour = moment(val).format('h')
                            date = moment(val).format('Do')
                            ampm = moment(val).format('a')
                            weekdaynum = moment(val).isoWeekday()
                            weekday = moment().isoWeekday(weekdaynum).format('dddd')
            
                            month = moment(val).format('MMMM')
                            year = moment(val).format('YYYY')
            
                            # datearray = [hour, minute, ampm, weekday, month, date, year]
                            datearray = [weekday, month]
                            datearray = _.map(datearray, (el)-> el.toString().toLowerCase())
    
                            
                            event.date_array = datearray
                            
                            tags = datearray
                          
                            tags.push event.venue.name
                            tags.push event.organizer.name
                            
                            if event.category 
                                for category_object in event.category
                                    tags push category_object.name
                            
                            trimmed_tags = _.map tags, (tag) ->
                                tag.trim().toLowerCase()
                            unique_tags = _.uniq trimmed_tags
                            event.tags = unique_tags 
                            
                            new_event_doc =
                                eventbrite_id: event.id
                                title: event.name.text
                                description: event.description.html
                                location: event.venue.name
                                start_datetime: event.start.local
                                end_datetime: event.end.local
                                type: 'event'
                                eventbrite_image: event.big_image_url
                                tags: event.tags
                                published: false
                                link: event.url
                            
                            new_event_id = Docs.insert new_event_doc
                            
                            console.log 'new_event_id', new_event_id
                            return new_event_id
                        console.log 'here?', new_event_id
                        return new_event_id
    
    
        # pull_url: (event_id)->
        #     HTTP.get "https://www.eventbriteapi.com/v3/events/#{event_id}", {
        #             params:
        #                 token: 'QLL5EULOADTSJDS74HH7'
        #                 # expand: 'organizer,venue,logo,format,category,subcategory,ticket_classes,bookmark_info'
        #         }, 
        #         (err, res)->
        #             if err
        #                 console.error err
        #             else
        #                 event = res.data
    
        #                 Docs.update event_id
        #                     url: event.url
