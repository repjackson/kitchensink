Meteor.publish 'doc', (id)->
    Docs.find id


Meteor.publish 'doc_tags', (selected_doc_tags, selected_authors, user_upvotes, user_downvotes, unvoted)->
    self = @

    match = {}
    if selected_doc_tags.length > 0 then match.tags = $all: selected_doc_tags
    if selected_authors.length > 0 then match.author_id = $in: selected_authors
    if user_upvotes then match.up_voters = $in: [user_upvotes]
    if user_downvotes then match.down_voters = $in: [user_downvotes]
    match.recipient_id = $exists: false
    if unvoted is true
        match.up_voters = $nin: [@userId]
        match.down_voters = $nin: [@userId]

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

Meteor.publish 'docs', (selected_doc_tags, selected_authors, user_upvotes, user_downvotes, unvoted)->
    match = {}
    # match.tag_count = $gt: 0
    if user_upvotes then match.up_voters = $in: [user_upvotes]
    if user_downvotes then match.down_voters = $in: [user_downvotes]
    if selected_authors.length > 0  then match.author_id = $in: selected_authors
    if selected_doc_tags.length > 0 then match.tags = $all: selected_doc_tags
    # match.tags = selected_doc_tags
    match.recipient_id = $exists: false
    if unvoted is true
        match.up_voters = $nin: [@userId]
        match.down_voters = $nin: [@userId]

    # console.log match

    Docs.find match,
        limit: 5
        sort:
            tag_count: 1
            points: -1
            timestamp: -1
