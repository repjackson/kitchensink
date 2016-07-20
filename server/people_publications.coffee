Meteor.publish 'authors', (selected_tags, selected_authors, view_mode)->
    self = @
    # if view_mode is 'mine' or 'unvoted' then return

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if selected_authors.length > 0 then match.author_id = $in: selected_authors
    # match.tagCount = $gt: 0
    switch view_mode
        when 'mine' then match.author_id = @userId
        when 'unvoted'
            match.up_voters = $nin: [@userId]
            match.down_voters = $nin: [@userId]


    cloud = Docs.aggregate [
        { $match: match }
        { $project: author_id: 1 }
        { $group: _id: '$author_id', count: $sum: 1 }
        { $match: _id: $nin: selected_authors }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, author_id: '$_id', count: 1 }
        ]

    # console.log 'author cloud:', cloud

    cloud.forEach (author) ->
        self.added 'authors', Random.id(),
            author_id: author.author_id
            count: author.count
    self.ready()

Meteor.publish 'leaderboard', ->
    Meteor.users.find {},
        fields:
            username: 1
            points: 1
            bookmarks: 1
            tags: 1
            up_voted_cloud_matches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1
            bookmarks: 1
            tag_cloud: 1
            taggers: 1
            user_tags: 1



Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields: 
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1
            points: 1
            bookmarks: 1
            up_voted_cloud_matches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1
            bookmarks: 1
            tag_cloud: 1
            taggers: 1
            user_tags: 1

            
Meteor.publish 'person', (person_id)-> 
    Meteor.users.find person_id,
        fields: 
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1
            points: 1
            bookmarks: 1
            up_voted_cloud_matches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1
            bookmarks: 1
            tag_cloud: 1
            taggers: 1
            user_tags: 1

            
            
            
Meteor.publish 'people_tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.$and =  
        [
            { recipient_id: $exists: true }
            { recipient_id: $ne: @userId }
        ]


    # console.log match
    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
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

Meteor.publish 'people', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.list = $all: selected_tags
    match["profile.name"] = $exists: false 
    Meteor.users.find match,
        fields:
            username: 1
            cloud: 1
            list: 1
            people_you_like: 1
            points: 1
            bookmarks: 1
            up_voted_cloud_matches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1
            bookmarks: 1
            tag_cloud: 1
            taggers: 1
            user_tags: 1

            
Meteor.publish 'people_you_like', ->
    me = Meteor.users.findOne @userId
    people_you_like = if me?.people_you_like then me.people_you_like else []

    Meteor.users.find { _id: $in: people_you_like },
        fields:
            username: 1
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1
            points: 1
            bookmarks: 1
            up_voted_cloud_matches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1
            bookmarks: 1
            tag_cloud: 1
            taggers: 1
            user_tags: 1

            
Meteor.publish 'people_who_like_you`', ->
    me = Meteor.users.findOne @userId

    Meteor.users.find { people_you_like: $in: @userId },
        fields:
            username: 1
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1
            points: 1
            bookmarks: 1
            up_voted_cloud_matches: 1
            downvoted_cloud: 1
            downvoted_list: 1
            upvoted_cloud: 1
            upvoted_list: 1
            authored_cloud: 1
            authored_list: 1
            bookmarks: 1
            tag_cloud: 1
            taggers: 1
            user_tags: 1
