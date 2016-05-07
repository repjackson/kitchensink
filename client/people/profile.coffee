@selectedtags = new ReactiveArray []


Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'myTags', selectedtags.array()
    @autorun -> Meteor.subscribe 'me'


Template.profile.helpers
    globalTags: ->
        # docCount = Docs.find().count()
        # if 0 < docCount < 3 then Tags.find { count: $lt: docCount } else Tags.find()
        Tags.find()

    # globalTagClass: ->
    #     buttonClass = switch
    #         when @index <= 20 then 'big'
    #         when @index <= 40 then 'large'
    #         when @index <= 60 then ''
    #         when @index <= 80 then 'small'
    #         when @index <= 100 then 'tiny'
    #     return buttonClass

    globalTagClass: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

    selectedtags: -> selectedtags.list()

    user: -> Meteor.user()

    people: -> Meteor.users.find()

    matchedUsersList:->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        userMatches = []
        for user in users
            tagIntersection = _.intersection(user.tags, Meteor.user().tags)
            userMatches.push
                matchedUser: user.username
                tagIntersection: tagIntersection
                length: tagIntersection.length
        sortedList = _.sortBy(userMatches, 'length').reverse()
        return sortedList

    upVotedMatchCloud: ->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        userMatchClouds = []
        for user in users
            my_upvoted_cloud = Meteor.user()._upvoted_cloud
            my_upvoted_list = Meteor.user().upvoted_list
            other_upvoted_cloud = user.upvoted_cloud
            other_upvoted_list = user.upvoted_list
            intersection = _.intersection(myupvoted_list, otherupvoted_list)
            intersectionCloud = []
            totalCount = 0
            for tag in intersection
                myTagObject = _.findWhere my_upvoted_cloud, name: tag
                hisTagObject = _.findWhere other_upvoted_cloud, name: tag
                min = Math.min(myTagObject.count, hisTagObject.count)
                totalCount += min
                intersectionCloud.push
                    tag: tag
                    min: min
            sortedCloud = _.sortBy(intersectionCloud, 'min').reverse()
            userMatchClouds.push
                matchedUser: user.username
                cloudIntersection: sortedCloud
                totalCount: totalCount


        sortedCloud = _.sortBy(userMatchClouds, 'totalCount').reverse()
        return sortedCloud


Template.profile.events
    'keydown #username': (e,t)->
        e.preventDefault
        username = $('#username').val().trim()
        switch e.which
            when 13
                if username.length > 0
                    Meteor.call 'update_username', username, (err,res)->
                        if err
                            alert 'username exists'
                            $('#username').val(Meteor.user().username)
                        else
                            alert "Updated username to #{username}"

    'keydown #addtag': (e,t)->
        e.preventDefault
        tag = $('#addtag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Meteor.call 'add_user_tag', tag, ->
                        $('#addtag').val('')

    'click .tag': ->
        tag = @valueOf()
        Meteor.call 'remove_user_tag', tag, ->
            $('#addtag').val(tag)