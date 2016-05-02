Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedtags, selected_user, user_upvotes, user_downvotes)->
    match = {}
    match.tagCount = $gt: 0
    if user_upvotes then match.up_voters = $in: [user_upvotes]
    if user_downvotes then match.down_voters = $in: [user_downvotes]
    if selected_user then match.authorId = selected_user
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    Docs.find match,
        limit: 10
        sort:
            tagCount: 1
            timestamp: -1

Accounts.onCreateUser (options, user) ->
    user.taggers = []
    user.userTags = []
    user.tagCloud = []
    user.tagList = []
    user.points = 0
    user


Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            tags: 1
            username: 1
            points: 1
            upVotedCloudMatches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1

Meteor.publish 'people', ->
    Meteor.users.find {},
        fields:
            tags: 1
            username: 1
            points: 1
            upVotedCloudMatches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1


Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            username: 1
            points: 1
            upVotedCloudMatches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1

Meteor.publish 'tags', (selectedTags, selected_user, user_upvotes, user_downvotes)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if user_upvotes then match.up_voters = $in: [user_upvotes]
    if user_downvotes then match.down_voters = $in: [user_downvotes]
    if selected_user then match.authorId = selected_user

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
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



Meteor.methods
    generatePersonalCloud: (uid)->
        authored_cloud = Docs.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        authored_list = (tag.name for tag in authored_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                authored_cloud: authored_cloud
                authored_list: authored_list


        upvoted_cloud = Docs.aggregate [
            { $match: up_voters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvoted_list = (tag.name for tag in upvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvoted_cloud: upvoted_cloud
                upvoted_list: upvoted_list


        downvoted_cloud = Docs.aggregate [
            { $match: down_voters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        downvoted_list = (tag.name for tag in downvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                downvoted_cloud: downvoted_cloud
                downvoted_list: downvoted_list

