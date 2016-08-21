Docs.allow
    insert: (userId, doc)-> doc.author_id is Meteor.userId()
    update: (userId, doc)-> doc.author_id is Meteor.userId()
    remove: (userId, doc)-> doc.author_id is Meteor.userId()




Meteor.publish 'doc', (id)-> Docs.find id



Meteor.publish 'tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

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
    # console.log 'cloud, ', cloud
    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()
    


Meteor.publish 'docs', (selected_tags)->
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    Docs.find match,
        sort:
            tag_count: 1
            timestamp: -1
        limit: 10



Meteor.methods
    generate_person_cloud: (uid)->
        cloud = Docs.aggregate [
            { $match: authorId: Meteor.userId() }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
            
        list = (tag.name for tag in cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                cloud: cloud
                list: list
