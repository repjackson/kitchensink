Template.docs.onCreated ->
    @autorun -> Meteor.subscribe 'docs', selectedTags.array(), Session.get('selected_user'), Session.get('upvoted_cloud'), Session.get('downvoted_cloud'), Session.get('unvoted')

Template.docs.helpers
    docs: -> Docs.find {},
        limit: 5
        sort:
            tagCount: 1
            timestamp: -1
    # docs: -> Docs.find()


Template.view.onCreated ->
    # console.log @data.authorId
    Meteor.subscribe 'person', @data.authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()

    when: -> moment(@timestamp).fromNow()

    user: -> Meteor.user()

    vote_upButtonClass: ->
        if not Meteor.userId() then 'disabled basic'
        else if Meteor.userId() in @up_voters then 'green'
        else 'basic'

    vote_downButtonClass: ->
        if not Meteor.userId() then 'disabled basic'
        else if Meteor.userId() in @down_voters then 'red'
        else 'basic'

    doc_tag_class: ->
        result = ''
        if @valueOf() in selectedTags.array() then result += ' primary' else result += ' basic'
        # if Meteor.userId() in Template.parentData(1).up_voters then result += ' green'
        # else if Meteor.userId() in Template.parentData(1).down_voters then result += ' red'
        return result

    select_user_button_class: -> if Session.equals 'selected_user', @authorId then 'primary' else 'basic'
    author_downvotes_button_class: -> if Session.equals 'downvoted_cloud', @authorId then 'primary' else 'basic'
    author_upvotes_button_class: -> if Session.equals 'upvoted_cloud', @authorId then 'primary' else 'basic'

    cloud_label_class: -> if @name in selectedTags.array() then 'primary' else 'basic'

    upVotedMatchCloud: ->
        my_upvoted_cloud = Meteor.user().upvoted_cloud
        myupvoted_list = Meteor.user().upvoted_list
        # console.log 'my_upvoted_cloud', my_upvoted_cloud
        # console.log @
        otherUser = Meteor.users.findOne @authorId
        other_upvoted_cloud = otherUser?.upvoted_cloud
        other_upvoted_list = otherUser?.upvoted_list
        # console.log 'otherCloud', other_upvoted_cloud
        intersection = _.intersection(myupvoted_list, other_upvoted_list)
        intersection_cloud = []
        totalCount = 0
        for tag in intersection
            myTagObject = _.findWhere my_upvoted_cloud, name: tag
            hisTagObject = _.findWhere other_upvoted_cloud, name: tag
            # console.log hisTagObject.count
            min = Math.min(myTagObject.count, hisTagObject.count)
            totalCount += min
            intersection_cloud.push
                tag: tag
                min: min
        sortedCloud = _.sortBy(intersection_cloud, 'min').reverse()
        result = {}
        result.cloud = sortedCloud
        result.totalCount = totalCount
        return result


Template.view.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .doc_tag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()

    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .authorFilterButton': ->
        if @username in selectedUsernames.array() then selectedUsernames.remove @username else selectedUsernames.push @username

    'click .cloneDoc': ->
        # if confirm 'Clone?'
        id = Docs.insert
            tags: @tags
            body: @body
        FlowRouter.go "/edit/#{id}"

    'click .vote_down': ->
        if Meteor.userId() in @down_voters
            if confirm "Undo Downvote? This will give you and #{@author().username} back a point."
                Meteor.call 'vote_down', @_id
        else
            if confirm "Confirm Downvote? This will cost you a point and take one from #{@author().username}"
                if Meteor.userId() then Meteor.call 'vote_down', @_id

    'click .vote_up': ->
        if Meteor.userId() in @up_voters
            if confirm "Undo Upvote? This will give you back a point and take one from #{@author().username}."
                Meteor.call 'vote_up', @_id
        else
            if confirm "Confirm Upvote? This will give a point from you to #{@author().username}."
                if Meteor.userId() then Meteor.call 'vote_up', @_id


    'click .select_user': ->
        if Session.equals('selected_user', @authorId) then Session.set('selected_user', null) else Session.set('selected_user', @authorId)
        Session.set 'downvoted_cloud', null
        Session.set 'upvoted_cloud', null

    'click .author_upvotes': ->
        if Session.equals('upvoted_cloud', @authorId) then Session.set('upvoted_cloud', null) else Session.set('upvoted_cloud', @authorId)
        Session.set 'selected_user', null
        Session.set 'downvoted_cloud', null

    'click .author_downvotes': ->
        if Session.equals('downvoted_cloud', @authorId) then Session.set('downvoted_cloud', null) else Session.set('downvoted_cloud', @authorId)
        Session.set 'selected_user', null
        Session.set 'upvoted_cloud', null


