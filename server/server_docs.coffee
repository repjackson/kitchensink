
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
        limit: 5
    


Meteor.methods
    alchemy_suggest: (id, body)->
        console.log 'analyzing body', body
        # result = HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
        HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/html/HTMLGetRankedKeywords', { params:
            # apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8' #old
            apikey: '4ddbab8b7ba51d6b36fe185c957ef602aff3f734' #new
            html: body
            outputMode: 'json'
            extract: 'keyword' }
            , (err, result)->
                if err then console.log err
                else
                    # console.log result
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    # concept_array = _.pluck(result.data.concepts, 'text')
                    loweredKeywords = _.map(keyword_array, (keyword)->
                        keyword.toLowerCase()
                        )

                    # console.log loweredKeywords
                    Docs.update id,
                        $set:
                            alchemy_tags: loweredKeywords
                            # tags: $each: loweredKeywords
