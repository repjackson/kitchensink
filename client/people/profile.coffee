@selectedTags = new ReactiveArray []


Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'messages'
    @autorun -> Meteor.subscribe 'myDocs', selectedTags.array()
    @autorun -> Meteor.subscribe 'myTags', selectedTags.array()



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

    selectedTags: -> selectedTags.list()

    user: -> Meteor.user()

    people: -> Meteor.users.find()

    myDocs: -> Docs.find()

    matchedUsersList:->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        userMatchClouds = []
        for user in users
            # console.log user.upvotedCloud
            # console.log user.upvotedList
            upvotedIntersection = _.intersection(user.upvotedList, Meteor.user().upvotedList)
            userMatchClouds.push
                matchedUser: user.username
                cloudIntersection: upvotedIntersection
                length: upvotedIntersection.length
        sortedList = _.sortBy(userMatchClouds, 'length').reverse()
        return sortedList

    upVotedMatchCloud: ->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        userMatchClouds = []
        for user in users
            myUpVotedCloud = Meteor.user().upvotedCloud
            myUpVotedList = Meteor.user().upvotedList
            # console.log 'myUpVotedCloud', myUpVotedCloud
            otherUpVotedCloud = user.upvotedCloud
            otherUpVotedList = user.upvotedList
            # console.log 'otherCloud', otherUpVotedCloud
            intersection = _.intersection(myUpVotedList, otherUpVotedList)
            intersectionCloud = []
            totalCount = 0
            for tag in intersection
                myTagObject = _.findWhere myUpVotedCloud, name: tag
                hisTagObject = _.findWhere otherUpVotedCloud, name: tag
                # console.log hisTagObject.count
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
    # 'click #generatePersonalCloud': ->
    #     Meteor.call 'generatePersonalCloud', Meteor.userId(), ->

    # 'click .matchTwoUsersAuthoredCloud': ->
    #     Meteor.call 'matchTwoUsersAuthoredCloud', @_id, ->

    'click .matchTwoUsersUpvotedCloud': ->
        Meteor.call 'matchTwoUsersUpvotedCloud', @_id, ->

    'click .selectTag': -> selectedTags.push @name
    'click .unselectTag': -> selectedTags.remove @valueOf()
    'click #clearTags': -> selectedTags.clear()


    'click .deleteDoc': ->
        # if confirm "Delete #{' '+tag for tag in @tags}?"
        Meteor.call 'removeDoc', @_id, (err,res)->
            if err then console.error err
            else
                Meteor.call 'generateAuthoredCloud', Meteor.userId()