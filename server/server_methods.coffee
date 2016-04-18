Meteor.methods
    generateAuthoredCloud: (uid)->
        authoredCloud = Docs.aggregate [
            { $match: authorId: uid }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 50 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        authoredList = (tag.name for tag in authoredCloud)
        Meteor.users.update Meteor.userId(),
            $set:
                authoredCloud: authoredCloud
                authoredList: authoredList


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