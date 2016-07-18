
Docs.allow
    insert: (userId, doc)-> doc.author_id is Meteor.userId()
    update: (userId, doc)-> doc.author_id is Meteor.userId()
    remove: (userId, doc)-> doc.author_id is Meteor.userId()

Meteor.publish 'doc', (id)->
    Docs.find id

Meteor.publish 'doc_tags', (selected_doc_tags)->
    self = @
    match = {}
    if selected_doc_tags.length > 0 then match.tags = $all: selected_doc_tags
    match.$and =  
        [
            { recipient_id: $exists: false }
            { recipient_id: $ne: @userId }
        ]


    # console.log match
    cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_doc_tags }
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

Meteor.publish 'docs', (selected_doc_tags)->
    self = @
    match = {}
    if selected_doc_tags.length > 0 then match.tags = $all: selected_doc_tags
    # match["profile.name"] = $exists: false 
    match.$and =  
        [
            { recipient_id: $exists: false }
            { recipient_id: $ne: @userId }
        ]

    Docs.find match,
        limit: 10
    


# Meteor.methods
#     generate_person_cloud: (user_id)->
#         cloud = Docs.aggregate [
#             { $match: recipient_id: user_id }
#             { $project: tags: 1 }
#             { $unwind: '$tags' }
#             { $group: _id: '$tags', count: $sum: 1 }
#             { $sort: count: -1, _id: 1 }
#             { $limit: 20 }
#             { $project: _id: 0, name: '$_id', count: 1 }
#             ]
            
#         list = (tag.name for tag in cloud)
#         Meteor.users.update user_id,
#             $set:
#                 cloud: cloud
#                 list: list

