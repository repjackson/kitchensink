Meteor.methods
    generatePersonalCloud: (uid)->
        authored_cloud = Docs.aggregate [
            { $match: authorId: Meteor.userId() }
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

    suggest_tags: (id, body)->
        doc = Docs.findOne id
        suggested_tags = Yaki(body).extract()
        cleaned_suggested_tags = Yaki(suggested_tags).clean()
        uniqued = _.uniq(cleaned_suggested_tags)
        lowered = uniqued.map (tag)-> tag.toLowerCase()

        #lowered = tag.toLowerCase() for tag in uniqued

        Docs.update id,
            $set: suggested_tags: lowered


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