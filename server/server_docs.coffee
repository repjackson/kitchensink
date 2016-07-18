

Meteor.publish 'doc_tags', (selected_doc_tags)->
    self = @
    match = {}
    if selected_doc_tags.length > 0 then match.tags = $all: selected_doc_tags
    # match.$and =  
    #     [
    #         { recipient_id: $exists: true }
    #         { recipient_id: $ne: @userId }
    #     ]


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
    Docs.find match


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

