@selected_tags = new ReactiveArray []

Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_tags.array()


Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'

    

Template.cloud.helpers
    all_tags: ->
        docCount = Docs.find().count()
        if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        # Tags.find()

    cloud_tag_class: ->
        buttonClass = switch
            when @index <= 5 then ''
            when @index <= 10 then ''
            when @index <= 15 then 'small'
            when @index <= 20 then 'tiny'
        return buttonClass

    selected_tags: -> selected_tags.list()


Template.docs.onCreated ->
    @autorun -> Meteor.subscribe('docs', selected_tags.array())


Template.docs.helpers
    docs: -> 
        Docs.find { }, 
            sort:
                tag_count: 1
            limit: 10

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

    is_editing: -> Session.equals 'editing', @_id 

Template.cloud.events
    'click .select_tag': -> selected_tags.push @name

    'click .unselect_tag': -> selected_tags.remove @valueOf()

    'click #clear_tags': -> selected_tags.clear()

    'keyup #add': (e,t)->
        e.preventDefault
        tag = $('#add').val().toLowerCase()
        if e.which is 13
            if tag.length > 0
                split_tags = tag.match(/\S+/g)
                $('#add').val('')
                Meteor.call 'add', split_tags
                selected_tags.clear()
                for tag in split_tags
                    selected_tags.push tag



Template.edit.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'doc', Session.get('editing')
        # self.subscribe 'tags', selected_type_of_event_tags.array(),"event"



Template.edit.helpers
    doc: -> Docs.findOne Session.get('editing')
    



        
Template.edit.events
    'click #delete_doc': ->
        Meteor.call 'delete', Session.get('editing'), (error, result) ->
            if error
                console.error error.reason
            else
                Session.set 'editing', null

    'keydown #add_tag': (e,t)->
        switch e.which
            when 13
                doc_id = Session.get('editing')
                tag = $('#add_tag').val().toLowerCase().trim()
                if tag.length > 0
                    Docs.update doc_id,
                        $addToSet: tags: tag
                    $('#add_tag').val('')
                else
                    Docs.update Session.get('editing'),
                        $set:
                            tag_count: @tags.length
                    selected_tags.clear()
                    for tag in @tags
                        selected_tags.push tag
                    Session.set 'editing', null

                    
    'click .doc_tag': (e,t)->
        doc = Docs.findOne Session.get('editing')
        tag = @valueOf()
        Docs.update Session.get('editing'),
            $pull: tags: tag
        $('#add_tag').val(tag)


    'click #save': ->
        Docs.update Session.get('editing'),
            $set:
                tag_count: @tags.length
        Session.set 'editing', null



Template.view.helpers
    is_author: -> Meteor.userId() and @author_id is Meteor.userId()

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

Template.view.events
    'click .tag': -> if @valueOf() in selected_tags.array() then selected_tags.remove(@valueOf()) else selected_tags.push(@valueOf())

    'click .edit': -> Session.set 'editing', @_id
