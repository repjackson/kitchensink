Meteor.methods
    createDoc: (tags=[])->
        Docs.insert
            tags: tags

    deleteDoc: (id)->
        Docs.remove id

    tagUser: (uId)->
        Meteor.users.update uId,
            $addToSet:
                taggers: Meteor.userId()

        Meteor.users.update Meteor.userId(),
            $addToSet:
                userTags:
                    uId: uId
                    tags: []

    addTag: (uId, tag)->
        user = Meteor.users.findOne uId
        if not user.tagCloud
            Meteor.users.update uId,
                $set: tagCloud: []
        if not user.tagList
            Meteor.users.update uId,
                $set: tagList: []


        if tag in user.tagList
            if tag in _.findWhere(Meteor.user().userTags, uId: uId).tags then return
            else
                Meteor.users.update {
                    _id: uId
                    'tagCloud.name': tag
                }, {$inc: 'tagCloud.$.count': 1}
        else
            Meteor.users.update uId,
                $addToSet:
                    tagList: tag
                    tagCloud:
                        name: tag
                        count: 1

        Meteor.users.update {
            _id: Meteor.userId()
            'userTags.uId': uId
        }, {$addToSet: 'userTags.$.tags': tag}


    removeUserTag: (uId, tag)->
        user = Meteor.users.findOne uId
        if _.findWhere(user.tagCloud, name: tag).count is 1
            Meteor.users.update uId,
                $pull:
                    tagCloud: name: tag
                    tagList: tag

        else
            Meteor.users.update {
                _id: uId
                'tagCloud.name': tag
            }, {$inc: 'tagCloud.$.count': -1}

        Meteor.users.update {
            _id: Meteor.userId()
            'userTags.uId': uId
        }, {$pull: 'userTags.$.tags': tag}



    generatePersonalCloud: (uid)->
        # authoredCloud = Docs.aggregate [
        #     { $match: authorId: uid }
        #     { $project: tags: 1 }
        #     { $unwind: '$tags' }
        #     { $group: _id: '$tags', count: $sum: 1 }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 50 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # authoredList = (tag.name for tag in authoredCloud)
        # Meteor.users.update Meteor.userId(),
        #     $set:
        #         authoredCloud: authoredCloud
        #         authoredList: authoredList


        upvotedCloud = Docs.aggregate [
            { $match: upVoters: $in: [Meteor.userId()] }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvotedList = (tag.name for tag in upvotedCloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvotedCloud: upvotedCloud
                upvotedList: upvotedList


    matchTwoDocs: (firstId, secondId)->
        firstDoc = Docs.findOne firstId
        secondDoc = Docs.findOne secondId

        firstTags = firstDoc.tags
        secondTags = secondDoc.tags

        intersection = _.intersection firstTags, secondTags
        intersectionCount = intersection.length

    findTopDocMatches: (docId)->
        thisDoc = Docs.findOne docId
        tags = thisDoc.tags
        matchObject = {}
        for tag in tags
            idArrayWithTag = []
            Docs.find({ tags: $in: [tag] }, { tags: 1 }).forEach (doc)->
                if doc._id isnt docId
                    idArrayWithTag.push doc._id
            matchObject[tag] = idArrayWithTag
        arrays = _.values matchObject
        flattenedArrays = _.flatten arrays
        countObject = {}
        for id in flattenedArrays
            if countObject[id]? then countObject[id]++ else countObject[id]=1
        # console.log countObject
        result = []
        for id, count of countObject
            comparedDoc = Docs.findOne(id)
            returnedObject = {}
            returnedObject.docId = id
            returnedObject.tags = comparedDoc.tags
            returnedObject.username = comparedDoc.username
            returnedObject.intersectionTags = _.intersection tags, comparedDoc.tags
            returnedObject.intersectionTagsCount = returnedObject.intersectionTags.length
            result.push returnedObject

        result = _.sortBy(result, 'intersectionTagsCount').reverse()
        result = result[0..5]
        Docs.update docId,
            $set: topDocMatches: result

        # console.log result
        return result

    matchTwoUsersAuthoredCloud: (uId)->
        username = Meteor.users.findOne(uId).username
        match = {}
        match.authorId = $in: [Meteor.userId(), uId]

        userMatchAuthoredCloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # authoredList = (tag.name for tag in userMatchAuthoredCloud)
        Meteor.users.update Meteor.userId(),
            $addToSet:
                authoredCloudMatches:
                    uId: uId
                    username: username
                    userMatchAuthoredCloud: userMatchAuthoredCloud

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

    createImporter: ->
        id = Importers.insert
            tags: []
            timestamp: Date.now()
            authorId: Meteor.userId()
            username: Meteor.user().username
        return id

    saveImporter: (id, importerName, importerTag)->
        Importers.update id,
            $set:
                name: importerName
                importerTag: importerTag

    testImporter: (iId)->
        importer = Importers.findOne iId
        pluckedNames = []
        testDoc = {}
        testDoc.tags = []
        testDoc.tags.push importer.importerTag
        for field in importer.fieldsObject
            if field.tag is true
                testDoc.tags.push field.firstValue
                pluckedNames.push field.name
        Importers.update iId,
            $set:
                testDoc: testDoc
                pluckedNames: pluckedNames

    runImporter: (id, amount=1000)->
        # importer = Importers.findOne id
        # HTTP.call importer.method, importer.url, {}, (err, result)->
        #     if err then console.error err
        #     else
        #         parsedContent = JSON.parse result.content

        #         features = parsedContent.features
        #         # console.log features[0].properties
        #         newDocs = (feature.properties for feature in features)
        #         for doc in newDocs
        #             id = Docs.insert
        #                 body: doc.CASE_DESCR
        #                 authorId: Meteor.userId()
        #                 timestamp: Date.now()
        #                 tags: ['boulder permits', doc.STAFF_EMAI?.toLowerCase(), doc.STAFF_PHON?.toLowerCase(), doc.STAFF_CONT?.toLowerCase(), doc.CASE_NUMBE?.toLowerCase(), doc.CASE_TYPE?.toLowerCase(), doc.APPLICANT_?.toLowerCase(), doc.CASE_ADDRE?.toLowerCase()]
        #             Meteor.call 'analyze', id, true

        importer = Importers.findOne id
        HTTP.get importer.downloadUrl, (err, result)->
            if err then console.error err
            else
                csvToParse = result.content
                # console.log csvToParse
                secondIteration = false
                Papa.parse csvToParse,
                    header: true
                    complete: (results, file) ->
                        if secondIteration then return
                        else
                            # slicedResults = results.data[0..amount]
                            slicedResults = results.data[0..2]
                            fieldNames = _.compact results.meta.fields
                            resultData = results.data
                            # console.log resultData.length
                            for row in resultData
                                tagsToInsert = []
                                tagsToInsert.push importer.importerTag
                                for field, value of row
                                    tagsToInsert.push "#{field}: #{value}"
                                Docs.insert
                                    tags: tagsToInsert
                            # for row in resultData
                            #     for name in fieldNames
                            #         fieldTagsToInsert = []
                            #         fieldTagsToInsert.push importer.importerTag
                            #         fieldTagsToInsert.push row['']
                            #         fieldTagsToInsert.push name
                            #         fieldTagsToInsert.push row[name]
                            #         console.log fieldTagsToInsert
                            #         Docs.insert
                            #             tags: fieldTagsToInsert
                            #     rowTagsToInsert = []
                            #     rowTagsToInsert.push importer.importerTag
                            #     rowTagsToInsert.push row['']
                            #     for name in fieldNames
                            #         # rowTagsToInsert.push name
                            #         rowTagsToInsert.push row[name]
                            #     console.log rowTagsToInsert
                            #     Docs.insert
                            #         tags: rowTagsToInsert



                            #     for name in importer.pluckedNames
                            #         tagsToInsert.push row[name]
                            secondIteration = true

                        # console.log results.data[0]
                        # fieldNames = results.meta.fields
                        # firstValues = _.values(results.data[0])
                        # fields = _.zip(fieldNames, firstValues)
                        # fieldsObject = _.map(fields, (field)->
                        #     name: field[0]
                        #     firstValue: field[1]
                        #     )
                        # Importers.update id,
                        #     $set:
                        #         fileName: name
                        #         fieldsObject: fieldsObject
                        # Meteor.call 'parseUpload', results.data, (err, res) ->
                        #     if err then console.log error.reason
                        #     else
                        #         template.uploading.set false
                        #         Bert.alert 'Upload complete', 'success', 'growl-top-right'

    cleanNonStringTags: ->
        uId = Meteor.userId()

        result = Docs.update({authorId: uId},
            {$pull: tags: $in: [ null ]},
            {multi: true})
        console.log result
        return result

    get_tweets: (screen_name)->
        if not screen_name
            console.error 'No screen name provided'
            return false
        existingDoc = Docs.findOne tags: $all: ['tweet', screen_name]
        if existingDoc
              throw new Meteor.Error('already-imported',"Tweets from #{screen_name} already exist")

        Twit = new TwitMaker(
            consumer_key: Meteor.settings.twitterConsumerKey
            consumer_secret: Meteor.settings.twitterSecret
            access_token: Meteor.settings.twitterAccessToken
            access_token_secret: Meteor.settings.twitterAccessTokenSecret
            app_only_auth:true)

        Twit.get 'statuses/user_timeline', {
            screen_name: screen_name
            count: 200
            include_rts: false
        }, Meteor.bindEnvironment(((err, data, response) ->
            for tweet in data
                id = Docs.insert
                    body: tweet.text
                Docs.update id,
                    $addToSet: tags: $each: ['tweet', screen_name]
                Meteor.call 'analyze', id, tweet.text
            ))



    analyze: (id, auto)->
        doc = Docs.findOne id
        encoded = encodeURIComponent(doc.body)

        # result = HTTP.call 'POST', 'http://gateway-a.watsonplatform.net/calls/text/TextGetCombinedData', { params:
        HTTP.call 'POST', 'http://access.alchemyapi.com/calls/html/HTMLGetCombinedData', { params:
            apikey: '6656fe7c66295e0a67d85c211066cf31b0a3d0c8'
            html: doc.body
            outputMode: 'json'
            extract: 'keyword' }
            , (err, result)->
                if err then console.log err
                else
                    keyword_array = _.pluck(result.data.keywords, 'text')
                    # concept_array = _.pluck(result.data.concepts, 'text')
                    loweredKeywords = _.map(keyword_array, (keyword)->
                        keyword.toLowerCase()
                        )

                    Docs.update id,
                        $addToSet:
                            keyword_array: $each: loweredKeywords
                            tags: $each: loweredKeywords


    fetchUrlTags: (docId, url)->
        doc = Docs.findOne docId
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

                    Docs.update docId,
                        $set:
                            body: result.data.text
                        $addToSet:
                            keyword_array: $each: loweredKeywords
                            tags: $each: loweredKeywords


    makeSuggestionsTagsIndividual: (id)->
        doc = Docs.findOne id
        Docs.update id,
            $addToSet:
                tags: doc.keyword_array

    makeSuggestionsTagsBulk: ->
        uId = Meteor.userId()

        result = Docs.update({authorId: uId},
            {$pull: tags: $in: [ null ]},
            {multi: true})
        console.log result
        return result

    findDocsWithTag: (tagSelector)->
        match = {}
        # match.authorId = Meteor.userId()
        match.tags = $in: [tagSelector]

        result = {}
        result.count = Docs.find(match).count()
        result.firstDoc = Docs.findOne(match)

        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        result.cloud = cloud
        return result

    deleteQueryDocs: (query)->
        Docs.remove
            tags: $in: [query]

