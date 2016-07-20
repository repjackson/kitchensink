Meteor.publish 'usernames', (selected_tags, selected_usernames, view_mode)->
    self = @
    # if view_mode is 'mine' or 'unvoted' then return

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if selected_usernames.length > 0 then match.author.username = $in: selected_usernames
    match.tagCount = $gt: 0
    switch view_mode
        when 'mine' then match.author_id = @userId
        when 'unvoted'
            match.up_voters = $nin: [@userId]
            match.down_voters = $nin: [@userId]


    cloud = Docs.aggregate [
        { $match: match }
        { $project: username: 1 }
        { $group: _id: '$username', count: $sum: 1 }
        { $match: _id: $nin: selected_usernames }
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
            bookmarks: 1
            


Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields: 
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1
            points: 1
            bookmarks: 1
            
Meteor.publish 'person', (person_id)-> 
    Meteor.users.find person_id,
        fields: 
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1
            points: 1
            bookmarks: 1
            
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
            