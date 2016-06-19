Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()

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
        { $limit: 7 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

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
        limit: 5
        sort:
            tag_count: 1
            points: 1
            # timestamp: -1
            
            
Meteor.methods
    yaki_suggest: (id)->
        doc = Docs.findOne id
        suggested_tags = Yaki(doc.body).extract()
        cleaned_suggested_tags = Yaki(suggested_tags).clean()
        uniqued = _.uniq(cleaned_suggested_tags)
        lowered = uniqued.map (tag)-> tag.toLowerCase()

        #lowered = tag.toLowerCase() for tag in uniqued

        Docs.update id,
            $set: yaki_tags: lowered

    alchemy_suggest: (id, body)->
        # console.log 'analyzing body', body
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
                        $addToSet:    
                            tags: $each: loweredKeywords
                    