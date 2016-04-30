@selectedTags = new ReactiveArray []


Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags', selectedTags.array())

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

    selectedTags: -> selectedTags.list()

    user: -> Meteor.user()

Template.cloud.events
    'click .selectTag': ->
        selectedTags.push @name
        FlowRouter.setQueryParams( filter: selectedTags.array() )
        console.log FlowRouter.getQueryParam('filter');

    'click .unselectTag': ->
        selectedTags.remove @valueOf()
        FlowRouter.setQueryParams( filter: selectedTags.array() )
        console.log FlowRouter.getQueryParam('filter');

    'click #clearTags': ->
        selectedTags.clear()
        FlowRouter.setQueryParams( filter: null )
        console.log FlowRouter.getQueryParam('filter');

    'click #bookmarkSelection': ->
        if confirm 'Bookmark Selection?'
            Meteor.call 'addBookmark', selectedTags.array(), (err,res)->
                alert "Selection bookmarked"

    'click #newFromSelection': ->
        if confirm 'Create new document from selection?'
            Meteor.call 'createDoc', selectedTags.array(), (err,id)->
                if err then console.log err
                else FlowRouter.go "/edit/#{id}"
