Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedtags, selected_user, user_upvotes, user_downvotes, unvoted)->
    match = {}
    match.tagCount = $gt: 0
    if user_upvotes then match.up_voters = $in: [user_upvotes]
    if user_downvotes then match.down_voters = $in: [user_downvotes]
    if selected_user then match.authorId = selected_user
    if selectedtags.length > 0 then match.tags = $all: selectedtags
    if unvoted is true
        match.up_voters = $nin: [@userId]
        match.down_voters = $nin: [@userId]

    Docs.find match,
        limit: 5
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
            bookmarks: 1
            tagCloud: 1
            taggers: 1
            userTags: 1

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
            bookmarks: 1
            tagCloud: 1
            taggers: 1
            userTags: 1

Meteor.publish 'filtered_people', (selectedUserTags)->
    self = @
    # console.log selectedTags
    match = {}
    if selectedUserTags and selectedUserTags.length > 0 then match.tagList = $all: selectedUserTags

    Meteor.users.find match,
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
            bookmarks: 1
            tagCloud: 1
            taggers: 1
            userTags: 1



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

Meteor.publish 'leaderboard', ->
    Meteor.users.find {},
        fields:
            username: 1
            points: 1


Meteor.publish 'userTags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags

    userCloud = Meteor.users.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
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
            bookmarks: 1
            tagCloud: 1
            taggers: 1
            userTags: 1

Meteor.publish 'tags', (selectedTags, selected_user, user_upvotes, user_downvotes, unvoted)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if user_upvotes then match.up_voters = $in: [user_upvotes]
    if user_downvotes then match.down_voters = $in: [user_downvotes]
    if selected_user then match.authorId = selected_user
    if unvoted is true
        match.up_voters = $nin: [@userId]
        match.down_voters = $nin: [@userId]


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
