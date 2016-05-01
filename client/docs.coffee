Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'docs', selectedTags.array(), Session.get('selected_user'), Session.get('upvoted_cloud'), Session.get('downvoted_cloud')

Template.docs.helpers
    # docs: -> Docs.find({}, limit: 1)
    docs: -> Docs.find()


Template.view.onCreated ->
    Meteor.subscribe 'person', @data.authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()

    when: -> moment(@timestamp).fromNow()

    vote_upButtonClass: ->
        if not Meteor.userId() then 'disabled basic'
        else if Meteor.userId() in @up_voters then 'green'
        else 'basic'

    vote_downButtonClass: ->
        if not Meteor.userId() then 'disabled basic'
        else if Meteor.userId() in @down_voters then 'red'
        else 'basic'

    docTagClass: ->
        result = ''
        if @valueOf() in selectedTags.array() then result += ' primary' else result += ' basic'
        if Meteor.userId() in Template.parentData(1).up_voters then result += ' green'
        else if Meteor.userId() in Template.parentData(1).down_voters then result += ' red'
        return result

    select_user_button_class: -> if Session.equals 'selected_user', @authorId then 'active' else ''
    author_downvotes_button_class: -> if Session.equals 'downvoted_cloud', @authorId then 'active' else ''
    author_upvotes_button_class: -> if Session.equals 'upvoted_cloud', @authorId then 'active' else ''

Template.view.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .docTag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()

    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .authorFilterButton': ->
        if @username in selectedUsernames.array() then selectedUsernames.remove @username else selectedUsernames.push @username

    'click .cloneDoc': ->
        # if confirm 'Clone?'
        id = Docs.insert
            tags: @tags
        FlowRouter.go "/edit/#{id}"

    'click .vote_down': ->
        if Meteor.userId()
            # if @points is 0 or (@points is 1 and Meteor.userId() in @up_voters)
            #     if confirm 'Confirm downvote? This will delete the doc.'
            #         Meteor.call 'vote_down', @_id
            # else
            Meteor.call 'vote_down', @_id

    'click .vote_up': -> if Meteor.userId() then Meteor.call 'vote_up', @_id

    'click .select_user': -> if Session.equals('selected_user', @authorId) then Session.set('selected_user', null) else Session.set('selected_user', @authorId)
    'click .author_upvotes': -> if Session.equals('upvoted_cloud', @authorId) then Session.set('upvoted_cloud', null) else Session.set('upvoted_cloud', @authorId)
    'click .author_downvotes': -> if Session.equals('downvoted_cloud', @authorId) then Session.set('downvoted_cloud', null) else Session.set('downvoted_cloud', @authorId)
