Accounts.onCreateUser (options, user) ->
    user.people_you_like = []
    user


Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields: 
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1

Meteor.publish 'tags', (selected_tags)->
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

Meteor.publish 'people_who_like_you`', ->
    me = Meteor.users.findOne @userId

    Meteor.users.find { people_you_like: $in: @userId },
        fields:
            username: 1
            cloud: 1
            list: 1
            contact: 1
            people_you_like: 1

Meteor.publish 'self_doc', ->
    # console.log 'publish self_doc'
    Docs.find
        recipient_id: @userId
        author_id: @userId


Meteor.publish 'review_doc', (recipient_id)->
    # console.log 'publish self_doc'
    Docs.find
        recipient_id: recipient_id
        author_id: @userId




Meteor.methods
    generate_person_cloud: (user_id)->
        cloud = Docs.aggregate [
            { $match: recipient_id: user_id }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
            
        list = (tag.name for tag in cloud)
        Meteor.users.update user_id,
            $set:
                cloud: cloud
                list: list

