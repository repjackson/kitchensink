Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'messages', ->
    Messages.find
        $or: [
            authorId: @userId
            toId: @userId
            ]
Meteor.publish 'importers', -> Importers.find { authorId: @userId}

Meteor.publish 'importer', (id)-> Importers.find id

Meteor.publish 'leaderboard', ->
    Meteor.users.find {},
        fields:
            username: 1
            points: 1


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



Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            username: 1
            taggers: 1
            userTags: 1
            upvotedCloud: 1
            points: 1
            upVotedCloudMatches: 1
            upvotedList: 1


Meteor.publish 'people', (selectedTags)->
    self = @
    # console.log selectedTags
    match = {}
    if selectedTags.length > 0 then match.tagList = $all: selectedTags

    Meteor.users.find match,
        fields:
            tagCloud: 1
            tagList: 1
            taggers: 1
            username: 1
            upvotedCloud: 1
            points: 1
            upVotedCloudMatches: 1
            upvotedList: 1



Meteor.publish 'docs', (selectedTags, selectedUsernames, viewMode)->
    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if selectedUsernames.length > 0 then match.username = $in: selectedUsernames
    match.tagCount = $gt: 0
    switch viewMode
        when 'mine' then match.authorId = @userId
        when 'unvoted'
            match.upVoters = $nin: [@userId]
            match.downVoters = $nin: [@userId]

    Docs.find match,
        limit: 10
        sort:
            tagCount: 1
            points: -1
            timestamp: -1

Meteor.publish 'usernames', (selectedTags, selectedUsernames, viewMode)->
    self = @
    # if viewMode is 'mine' or 'unvoted' then return

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if selectedUsernames.length > 0 then match.username = $in: selectedUsernames
    match.tagCount = $gt: 0
    switch viewMode
        when 'mine' then match.authorId = @userId
        when 'unvoted'
            match.upVoters = $nin: [@userId]
            match.downVoters = $nin: [@userId]


    cloud = Docs.aggregate [
        { $match: match }
        { $project: username: 1 }
        { $group: _id: '$username', count: $sum: 1 }
        { $match: _id: $nin: selectedUsernames }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, text: '$_id', count: 1 }
        ]

    cloud.forEach (username) ->
        self.added 'usernames', Random.id(),
            text: username.text
            count: username.count
    self.ready()






# count combining
# Meteor.publish 'tags', (selectedTags, viewMode)->
#     self = @

#     match = {}
#     if selectedTags.length > 0 then match.tags = $all: selectedTags
#     switch viewMode
#         when 'mine' then match.authorId = @userId
#         when 'unvoted'
#             match.upVoters = $nin: [@userId]
#             match.downVoters = $nin: [@userId]

#     cloud = Docs.aggregate [
#         { $match: match }
#         { $project: tags: 1, points: 1 }
#         { $unwind: '$tags' }
#         {
#             $group:
#                 _id:'$tags'
#                 count: $sum:1
#                 tagPoints: $sum:'$points'
#         }
#         { $match: _id: $nin: selectedTags }
#         # { $sort: count: -1, _id: 1 }
#         { $limit: 50 }
#         { $project: _id:0, name:'$_id', count:1 , countPlusPoints: '$add':['$count', '$tagPoints'] }
#         { $sort: countPlusPoints: -1 }
#         ]

#     cloud.forEach (tag, i) ->
#         self.added 'tags', Random.id(),
#             name: tag.name
#             count: tag.count
#             countPlusPoints: tag.countPlusPoints
#             index: i

#     self.ready()


Meteor.publish 'userTags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags

    userCloud = Meteor.users.aggregate [
        { $match: match }
        { $project: tagList: 1 }
        { $unwind: '$tagList' }
        { $group: _id: '$tagList', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    userCloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

Meteor.publish 'docTags', (selectedTags, selectedUsernames, viewMode)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if selectedUsernames.length > 0 then match.username = $in: selectedUsernames
    switch viewMode
        when 'mine' then match.authorId = @userId
        when 'unvoted'
            match.upVoters = $nin: [@userId]
            match.downVoters = $nin: [@userId]

    docCloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    docCloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i


    self.ready()

