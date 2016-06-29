Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

Meteor.publish 'doc', (id)-> Docs.find id

Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields: 
            points: 1
            bookmarks: 1

Meteor.publish 'tags', (selected_tags)->
    self = @

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.tag_count = $gt: 0

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
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

Meteor.publish 'docs', (selected_tags)->
    # Counts.publish(this, 'doc_counter', Docs.find(), { noReady: true })

    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    # match.tag_count = $exists: true
    match.tag_count = $gt: 0
    Docs.find match,
        limit: 10
        sort:
            tag_count: 1
            # points: -1
            # timestamp: -1