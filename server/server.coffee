Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedTags)->
    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    match.tagCount = $gt: 0

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
    user


Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            tags: 1
            username: 1
            taggers: 1
            upvotedCloud: 1
            points: 1
            upVotedCloudMatches: 1
            upvotedList: 1


Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            username: 1
            bookmarks: 1

Meteor.publish 'tags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags

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
        # authoredCloud = Docs.aggregate [
        #     { $match: authorId: uid }
        #     { $project: tags: 1 }
        #     { $unwind: '$tags' }
        #     { $group: _id: '$tags', count: $sum: 1 }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 50 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # authoredList = (tag.name for tag in authoredCloud)
        # Meteor.users.update Meteor.userId(),
        #     $set:
        #         authoredCloud: authoredCloud
        #         authoredList: authoredList


        upvotedCloud = Docs.aggregate [
            { $match: upVoters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvotedList = (tag.name for tag in upvotedCloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvotedCloud: upvotedCloud
                upvotedList: upvotedList
