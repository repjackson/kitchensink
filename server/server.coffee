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

Meteor.publish 'doc', (id)-> Docs.find id


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