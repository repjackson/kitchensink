Meteor.publish 'authored_intersection_tags', (authorId)->
    author_list = Meteor.users.findOne(authorId).authored_list
    author_tags = Meteor.users.findOne(authorId).authored_cloud

    your_list = Meteor.user().authored_list
    your_tags = Meteor.user().authored_cloud

    list_intersection = _.intersection(author_list, your_list)

    intersection_tags = []
    for tag in list_intersection
        author_count = author_tags.tag.count
        your_count = your_tags.tag.count
        lower_value = Meth.min(author_count, your_count)
        cloud_object = name: tag, count: lower_value
        intersection_tags.push cloud_object

    console.log intersection_tags

    intersection_tags.forEach (tag) ->
        self.added 'authored_intersection_tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()

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

Meteor.publish 'store', ->
    Docs.find {tags: $in: ['store']},
        limit: 5
        sort:
            tagCount: 1
            timestamp: -1

Accounts.onCreateUser (options, user) ->
    user.taggers = []
    user.userTags = []
    user.tagCloud = []
    user.tagList = []
    user.points = 100
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
