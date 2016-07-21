
Docs.allow
    insert: (userId, doc)-> doc.author_id is Meteor.userId()
    update: (userId, doc)-> doc.author_id is Meteor.userId()
    remove: (userId, doc)-> doc.author_id is Meteor.userId()



Meteor.methods
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
                            # tags: $each: loweredKeywords

    yaki_suggest: (id)->
        doc = Docs.findOne id
        suggested_tags = Yaki(doc.body).extract()
        cleaned_suggested_tags = Yaki(suggested_tags).clean()
        uniqued = _.uniq(cleaned_suggested_tags)
        lowered = uniqued.map (tag)-> tag.toLowerCase()

        #lowered = tag.toLowerCase() for tag in uniqued

        Docs.update id,
            $set: yaki_tags: lowered


    generate_person_cloud: (uid)->
        authored_cloud = Docs.aggregate [
            { $match: author_id: Meteor.userId() }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        authored_list = (tag.name for tag in authored_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                authored_cloud: authored_cloud
                authored_list: authored_list


        upvoted_cloud = Docs.aggregate [
            { $match: up_voters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvoted_list = (tag.name for tag in upvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvoted_cloud: upvoted_cloud
                upvoted_list: upvoted_list


        downvoted_cloud = Docs.aggregate [
            { $match: down_voters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        downvoted_list = (tag.name for tag in downvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                downvoted_cloud: downvoted_cloud
                downvoted_list: downvoted_list




    match_two_docs: (first_id, second_id)->
        first_doc = Docs.findOne first_id
        second_doc = Docs.findOne second_id

        first_tags = first_doc.tags
        second_tags = second_doc.tags

        intersection = _.intersection first_tags, second_tags
        intersection_count = intersection.length

    find_top_doc_matches: (doc_id)->
        this_doc = Docs.findOne doc_id
        tags = this_doc.tags
        match_object = {}
        for tag in tags
            idArrayWithTag = []
            Docs.find({ tags: $in: [tag] }, { tags: 1 }).forEach (doc)->
                if doc._id isnt doc_id
                    idArrayWithTag.push doc._id
            match_object[tag] = idArrayWithTag
        arrays = _.values match_object
        flattenedArrays = _.flatten arrays
        count_object = {}
        for id in flattenedArrays
            if count_object[id]? then count_object[id]++ else count_object[id]=1
        # console.log count_object
        result = []
        for id, count of count_object
            comparedDoc = Docs.findOne(id)
            returned_object = {}
            returned_object.doc_id = id
            returned_object.tags = comparedDoc.tags
            returned_object.username = comparedDoc.username
            returned_object.intersection_tags = _.intersection tags, comparedDoc.tags
            returned_object.intersection_tagsCount = returned_object.intersection_tags.length
            result.push returned_object

        result = _.sortBy(result, 'intersection_tags_count').reverse()
        result = result[0..5]
        Docs.update doc_id,
            $set: top_doc_matches: result

        # console.log result
        return result

    match_two_users_authored_cloud: (uId)->
        username = Meteor.users.findOne(uId).username
        match = {}
        match.authorId = $in: [Meteor.userId(), uId]

        user_match_authored_cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # authoredList = (tag.name for tag in user_match_authored_cloud)
        Meteor.users.update Meteor.userId(),
            $addToSet:
                authoredCloudMatches:
                    uId: uId
                    username: username
                    user_match_authored_cloud: user_match_authored_cloud

    matchTwoUsersUpvotedCloud: (uId)->
        username = Meteor.users.findOne(uId).username
        match = {}
        match.upVoters = $in: [Meteor.userId(), uId]

        userMatchUpvotedCloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        Meteor.users.update Meteor.userId(),
            $addToSet:
                upVotedCloudMatches:
                    uId: uId
                    username: username
                    userMatchUpvotedCloud: userMatchUpvotedCloud

    fetch_url_tags: (doc_id, url)->
        doc = Docs.findOne doc_id
        HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/url/URLGetRankedKeywords', { params:
            apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8'
            url: url
            keywordExtractMode: 'normal'
            outputMode: 'json'
            showSourceText: 1
            sourceText: 'cleaned_or_raw'
            knowledgeGraph: 0
            extract: 'keyword' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    # concept_array = _.pluck(result.data.concepts, 'text')
                    loweredKeywords = _.map(keyword_array, (keyword)->
                        keyword.toLowerCase()
                        )

                    Docs.update doc_id,
                        $set:
                            body: result.data.text
                        $addToSet:
                            keyword_array: $each: loweredKeywords
                            # tags: $each: loweredKeywords


