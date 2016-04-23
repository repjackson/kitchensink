Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            tags: 1
            profile: 1
            username: 1

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            profile: 1
            username: 1


Meteor.publish 'people', (selectedtags)->
    self = @
    match = {}
    if selectedtags and selectedtags.length > 0 then match.tags = $all: selectedtags

    Meteor.users.find match,
        fields:
            tags: 1
            profile: 1
            username: 1


Meteor.publish 'tags', (selectedtags)->
    self = @
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    tagCloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    tagCloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

