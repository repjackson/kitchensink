Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields: 
            points: 1
            tags: 1

Meteor.publish 'tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match._id = $ne: @userId

    cloud = Meteor.users.aggregate [
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

Meteor.publish 'people', (selected_tags=[])->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    Meteor.users.find match,
        fields:
            tags: 1
            profile: 1
            username: 1


Meteor.publish 'self_doc', ->
    # console.log 'publish self_doc'
    Docs.find
        recipient_id: @userId
        author_id: @userId
