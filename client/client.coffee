@selected_tags = new ReactiveArray []

Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_tags.array()
    @autorun -> Meteor.subscribe 'me'



Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'

    

Template.cloud.helpers
    all_tags: ->
        # docCount = Docs.find().count()
        # if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find( {})
        Tags.find()

    me: -> Meteor.user()


    one_left: ->
        doc_count = Docs.find().count()
        doc_count is 1
        
    last_doc: ->
        Docs.findOne()

    # zero_five: ->
    #     Tags.find
    #         index: $lt: 5

    # six_twelve: ->
    #     Tags.find
    #         index: 
    #             $gt: 5
    #             $lt: 12

    # thirteen_twenty: ->
    #     Tags.find
    #         index: 
    #             $gt: 12
    #             $lt: 20

    cloud_tag_class: ->
        buttonClass = switch
            when @index <= 5 then ''
            when @index <= 12 then 'small'
            when @index <= 20 then 'tiny'
        return buttonClass

    selected_tags: -> selected_tags.list()

    # settings: ->
    #     {
    #         position: 'bottom'
    #         limit: 10
    #         rules: [
    #             {
    #                 # token: ''
    #                 collection: Tags
    #                 field: 'name'
    #                 matchAll: true
    #                 template: Template.tag_result
    #             }
    #         ]
        # }



Template.docs.onCreated ->
    @autorun -> Meteor.subscribe('docs', selected_tags.array())


Template.docs.helpers
    docs: -> 
        Docs.find { }, 
            sort:
                points: -1
                tag_count: 1
            limit: 10

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

    # is_editing: -> Session.equals 'editing', @_id 

Template.cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()

    'click #add': -> 
        Meteor.call 'add', selected_tags.array(), (err, id)->
            FlowRouter.go "/edit/#{id}"


    'keyup #quick_add': (e,t)->
        e.preventDefault
        tag = $('#quick_add').val().toLowerCase()
        if e.which is 13
            if tag.length > 0
                split_tags = tag.match(/\S+/g)
                $('#quick_add').val('')
                Meteor.call 'add', split_tags
                selected_tags.clear()
                for tag in split_tags
                    selected_tags.push tag

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
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
                    
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_tags.push doc.name
        $('#search').val ''



Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', FlowRouter.getParam('doc_id')
        # self.subscribe 'tags', selected_type_of_event_tags.array(),"event"

Template.view.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'person', Template.currentData().author_id
        # self.subscribe 'tags', selected_type_of_event_tags.array(),"event"



Template.edit.helpers
    doc: -> Docs.findOne FlowRouter.getParam('doc_id')
    

        
Template.edit.events
    'click #delete_doc': ->
        Meteor.call 'delete', FlowRouter.getParam('doc_id'), (error, result) ->
            if error
                console.error error.reason
            else
                Session.set 'editing', null

    'keydown #add_tag': (e,t)->
        switch e.which
            when 13
                doc_id = FlowRouter.getParam('doc_id')
                tag = $('#add_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Docs.update doc_id,
                        $addToSet: tags: tag
                    $('#add_tag').val('')
                else
                    Docs.update FlowRouter.getParam('doc_id'),
                        $set:
                            tag_count: @tags.length
                    Meteor.call 'generate_person_cloud', Meteor.userId()
                    Session.set 'editing', null

                    
    'click .doc_tag': (e,t)->
        doc = Docs.findOne FlowRouter.getParam('doc_id')
        tag = @valueOf()
        Docs.update FlowRouter.getParam('doc_id'),
            $pull: tags: tag
        $('#add_tag').val(tag)


    'click #save': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set:
                tag_count: @tags.length
        Meteor.call 'generate_person_cloud', Meteor.userId()
        Session.set 'editing', null



Template.view.helpers
    is_author: -> Meteor.userId() and @author_id is Meteor.userId()
    is_mine: -> 
        last_doc = Docs.findOne()
        console.log last_doc
        Meteor.userId() and last_doc.author_id is Meteor.userId()

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

    # when: -> moment(@timestamp).fromNow()
    
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled basic'
        # else if Meteor.user().points < 1 then 'disabled basic'
        else if Meteor.userId() in @up_voters then 'green'
        else 'basic'

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled basic'
        # else if Meteor.user().points < 1 then 'disabled basic'
        else if Meteor.userId() in @down_voters then 'red'
        else 'basic'


Template.view.events
    'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

    'click .edit': -> FlowRouter.go("/edit/#{@_id}")

    'click .vote_up': -> Meteor.call 'vote_up', @_id

    'click .vote_down': -> Meteor.call 'vote_down', @_id
