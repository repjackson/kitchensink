@selected_tags = new ReactiveArray []


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'



Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'docs', selected_tags.array()

Template.docs.helpers
    docs: -> Docs.find {},
        limit: 5
        sort:
            tag_count: 1
            timestamp: -1
    # docs: -> Docs.find()
    
Template.layout.helpers
    is_editing: -> Session.get 'editing'


Template.view.onCreated ->
    # console.log @data.authorId
    Meteor.subscribe 'person', @data.authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()
    
    doc_tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

    cloud_label_class: -> if @name in selected_tags.array() then 'primary' else ''


Template.view.events
    'click .edit_doc': -> Session.set 'editing', @_id

    'click .doc_tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()

    'click .delete_doc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id




Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_tags.array()

# Template.cloud.onRendered ->
#     bubbleChart = new (d3.svg.BubbleChart)(
#         supportResponsive: true
#         size: 600
#         innerRadius: 600 / 3.5
#         radiusMin: 50
#         data:
#             items: [
#                 {
#                     text: 'Java'
#                     count: '236'
#                 }
#                 {
#                     text: '.Net'
#                     count: '382'
#                 }
#                 {
#                     text: 'Php'
#                     count: '170'
#                 }
#                 {
#                     text: 'Ruby'
#                     count: '123'
#                 }
#                 {
#                     text: 'D'
#                     count: '12'
#                 }
#                 {
#                     text: 'Python'
#                     count: '170'
#                 }
#                 {
#                     text: 'C/C++'
#                     count: '382'
#                 }
#                 {
#                     text: 'Pascal'
#                     count: '10'
#                 }
#                 {
#                     text: 'Something'
#                     count: '170'
#                 }
#             ]
#             eval: (item) ->
#                 item.count
#             classed: (item) ->
#                 item.text.split(' ').join ''
#         plugins: [
#             {
#                 name: 'central-click'
#                 options:
#                     text: '(See more detail)'
#                     style:
#                         'font-size': '12px'
#                         'font-style': 'italic'
#                         'font-family': 'Source Sans Pro, sans-serif'
#                         'text-anchor': 'middle'
#                         'fill': 'white'
#                     attr: dy: '65px'
#                     centralClick: ->
#                         alert 'Here is more details!!'
#                         return

#             }
#             {
#                 name: 'lines'
#                 options:
#                     format: [
#                         {
#                             textField: 'count'
#                             classed: count: true
#                             style:
#                                 'font-size': '28px'
#                                 'font-family': 'Source Sans Pro, sans-serif'
#                                 'text-anchor': 'middle'
#                                 fill: 'white'
#                             attr:
#                                 dy: '0px'
#                                 x: (d) ->
#                                     d.cx
#                                 y: (d) ->
#                                     d.cy

#                         }
#                         {
#                             textField: 'text'
#                             classed: text: true
#                             style:
#                                 'font-size': '14px'
#                                 'font-family': 'Source Sans Pro, sans-serif'
#                                 'text-anchor': 'middle'
#                                 fill: 'white'
#                             attr:
#                                 dy: '20px'
#                                 x: (d) ->
#                                     d.cx
#                                 y: (d) ->
#                                     d.cy

#                         }
#                     ]
#                     centralFormat: [
#                         {
#                             style: 'font-size': '50px'
#                             attr: {}
#                         }
#                         {
#                             style: 'font-size': '30px'
#                             attr: dy: '40px'
#                         }
#                     ]
#             }
#         ])
#     return

Template.cloud.helpers
    globalTags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        # Tags.find()


    globalTagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass


    selected_tags: -> selected_tags.list()


Template.cloud.events
    'click #add_doc': ->
        Meteor.call 'create_doc', (err, id)->
            if err then console.log err
            else Session.set 'editing', id

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_tags.pop()

    'click .selectTag': -> selected_tags.push @name

    'click .unselectTag': -> selected_tags.remove @valueOf()

    'click #clearTags': -> selected_tags.clear()
