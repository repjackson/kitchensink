Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields: 
            tag_list: 1
            tag_cloud: 1
            
Meteor.publish 'everyone', ()-> 
    Meteor.users.find {},
        fields: 
            tag_list: 1
            tag_cloud: 1
            username: 1
            
            
            

Meteor.publish 'tags', (selected_tags)->
    self = @

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.tag_count = $gt: 0

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

Meteor.publish 'docs', (selected_tags)->
    # Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    # match.tag_count = $exists: true
    match.tag_count = $gt: 0
    Docs.find match,
        limit: 10
        sort:
            tag_count: 1
            # points: -1
            # timestamp: -1
            
Meteor.publish 'user_matches', (selected_tags) ->
    self = @
    # debugger
    match = {}
    if selected_tags.length > 0 then match.tag_list = $all: selected_tags
    match._id = $ne: @userId

    users = Meteor.users.find(match).
    user_matches = []
    for user in users
        tag_intersection = _.intersection(user.tag_list, Meteor.user().tag_list)
        user_matches.push
            matched_user: user.username
            tag_intersection: tag_intersection
            length: tag_intersection.length
    sorted_list = _.sortBy(user_matches, 'length').reverse()

    sorted_list.forEach (user, i) ->
        self.added 'user_matches', Random.id(),
            matched_user: user.matched_user
            tag_intersection: user.tag_intersection
            length: user.tag_intersection.length
            index: i

    self.ready()

    
    
Meteor.methods
    generate_user_cloud: ->
        tag_cloud = Docs.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        tag_list = (tag.name for tag in tag_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                tag_cloud: tag_cloud
                tag_list: tag_list

    matchedUsersList:->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        userMatches = []
        for user in users
            tagIntersection = _.intersection(user.tag_list, Meteor.user().tag_list)
            userMatches.push
                matchedUser: user.username
                tagIntersection: tagIntersection
                length: tagIntersection.length
        sorted_list = _.sortBy(userMatches, 'length').reverse()
        return sorted_list

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
