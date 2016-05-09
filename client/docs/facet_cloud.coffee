@selectedTags = new ReactiveArray []
@selectedUsernames = new ReactiveArray []


Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selectedTags.array(), Session.get('selected_user'), Session.get('upvoted_cloud'), Session.get('downvoted_cloud'), Session.get('unvoted')
    @autorun -> Meteor.subscribe('usernames', selectedTags.array(), selectedUsernames.array(), Session.get('view'))


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

    unvoted_button_class: -> if Session.equals('unvoted', true) then 'grey' else 'basic'

    selectedTags: -> selectedTags.list()

    user: -> Meteor.user()
    selected_user: -> if Session.get 'selected_user' then Meteor.users.findOne(Session.get('selected_user'))?.username

    upvoted_cloud: -> if Session.get 'upvoted_cloud' then Meteor.users.findOne(Session.get('upvoted_cloud'))?.username

    downvoted_cloud: -> if Session.get 'downvoted_cloud' then Meteor.users.findOne(Session.get('downvoted_cloud'))?.username

    globalUsernames: -> Usernames.find()
    selectedUsernames: -> selectedUsernames.list()


Template.cloud.events
    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selectedTags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selectedTags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selectedTags.pop()

    'click .selectTag': ->
        selectedTags.push @name
        FlowRouter.setQueryParams( filter: selectedTags.array() )
        # console.log FlowRouter.getQueryParam('filter');

    'click .unselectTag': ->
        selectedTags.remove @valueOf()
        FlowRouter.setQueryParams( filter: selectedTags.array() )
        # console.log FlowRouter.getQueryParam('filter');

    'click #clearTags': ->
        selectedTags.clear()
        FlowRouter.setQueryParams( filter: null )
        # console.log FlowRouter.getQueryParam('filter');

    'click #bookmarkSelection': ->
        # if confirm 'Bookmark Selection?'
        Meteor.call 'addBookmark', selectedTags.array(), (err,res)->
            alert "Selection bookmarked"

    'click .selected_user_button': -> Session.set 'selected_user', null
    'click .upvoted_cloud_button': -> Session.set 'upvoted_cloud', null
    'click .downvoted_cloud_button': -> Session.set 'downvoted_cloud', null

    'click #mine': ->
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null
        Session.set 'selected_user', Meteor.userId()

    'click #my_upvoted': ->
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', Meteor.userId()

    'click #my_downvoted': ->
        Session.set 'selected_user', null
        Session.set 'upvoted_cloud', null
        Session.set 'downvoted_cloud', Meteor.userId()

    'click #unvoted': ->
        if Session.equals('unvoted', true) then Session.set('unvoted', false) else Session.set('unvoted', true)


    'click .selectUsername': -> selectedUsernames.push @text
    'click .unselectUsername': -> selectedUsernames.remove @valueOf()
    'click #clearUsernames': -> selectedUsernames.clear()
