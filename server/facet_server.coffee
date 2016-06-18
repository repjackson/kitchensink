Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Meteor.publish 'docs', (selectedtags)->
    match = {}
    match.tagCount = $gt: 0
    if selectedtags.length > 0 then match.tags = $all: selectedtags

    Docs.find match,
        limit: 1
        sort:
            tagCount: 1
            timestamp: -1

Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            username: 1
            points: 1

Meteor.publish 'people', ->
    Meteor.users.find {},
        fields:
            tags: 1
            username: 1
            points: 1

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            username: 1
            points: 1

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
        { $limit: 7 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()
