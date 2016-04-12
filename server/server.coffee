# Meteor.publish 'person', (id)->
#     Meteor.users.find id,
#         fields:
#             tags: 1
#             username: 1
#             taggers: 1

Accounts.onCreateUser (options, user) ->
    user.taggers = []
    user.userTags = []
    user.tagCloud = []
    user.tagList = []
    user



Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            username: 1
            taggers: 1
            userTags: 1

Meteor.publish 'people', (selectedTags)->
    self = @
    # console.log selectedTags
    match = {}
    if selectedTags.length > 0 then match.tagList = $all: selectedTags

    Meteor.users.find match,
        fields:
            tagCloud: 1
            tagList: 1
            taggers: 1
            username: 1





# count combining
# Meteor.publish 'tags', (selectedTags, viewMode)->
#     self = @

#     match = {}
#     if selectedTags.length > 0 then match.tags = $all: selectedTags
#     switch viewMode
#         when 'mine' then match.authorId = @userId
#         when 'unvoted'
#             match.upVoters = $nin: [@userId]
#             match.downVoters = $nin: [@userId]

#     cloud = Docs.aggregate [
#         { $match: match }
#         { $project: tags: 1, points: 1 }
#         { $unwind: '$tags' }
#         {
#             $group:
#                 _id:'$tags'
#                 count: $sum:1
#                 tagPoints: $sum:'$points'
#         }
#         { $match: _id: $nin: selectedTags }
#         # { $sort: count: -1, _id: 1 }
#         { $limit: 50 }
#         { $project: _id:0, name:'$_id', count:1 , countPlusPoints: '$add':['$count', '$tagPoints'] }
#         { $sort: countPlusPoints: -1 }
#         ]

#     cloud.forEach (tag, i) ->
#         self.added 'tags', Random.id(),
#             name: tag.name
#             count: tag.count
#             countPlusPoints: tag.countPlusPoints
#             index: i

#     self.ready()


Meteor.publish 'tags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags

    cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: tagList: 1 }
        { $unwind: '$tagList' }
        { $group: _id: '$tagList', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
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



Meteor.methods
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



    # generatePersonalCloud: (uid)->
    #     # authoredCloud = Docs.aggregate [
    #     #     { $match: authorId: uid }
    #     #     { $project: tags: 1 }
    #     #     { $unwind: '$tags' }
    #     #     { $group: _id: '$tags', count: $sum: 1 }
    #     #     { $sort: count: -1, _id: 1 }
    #     #     { $limit: 50 }
    #     #     { $project: _id: 0, name: '$_id', count: 1 }
    #     #     ]
    #     # authoredList = (tag.name for tag in authoredCloud)
    #     # Meteor.users.update Meteor.userId(),
    #     #     $set:
    #     #         authoredCloud: authoredCloud
    #     #         authoredList: authoredList


    #     upvotedCloud = Docs.aggregate [
    #         { $match: upVoters: $in: [Meteor.userId()] }
    #         { $project: tags: 1 }
    #         { $unwind: '$tags' }
    #         { $group: _id: '$tags', count: $sum: 1 }
    #         { $sort: count: -1, _id: 1 }
    #         { $limit: 100 }
    #         { $project: _id: 0, name: '$_id', count: 1 }
    #         ]
    #     upvotedList = (tag.name for tag in upvotedCloud)
    #     Meteor.users.update Meteor.userId(),
    #         $set:
    #             upvotedCloud: upvotedCloud
    #             upvotedList: upvotedList


    # matchTwoDocs: (firstId, secondId)->
    #     firstDoc = Docs.findOne firstId
    #     secondDoc = Docs.findOne secondId

    #     firstTags = firstDoc.tags
    #     secondTags = secondDoc.tags

    #     intersection = _.intersection firstTags, secondTags
    #     intersectionCount = intersection.length

    # findTopDocMatches: (docId)->
    #     thisDoc = Docs.findOne docId
    #     tags = thisDoc.tags
    #     matchObject = {}
    #     for tag in tags
    #         idArrayWithTag = []
    #         Docs.find({ tags: $in: [tag] }, { tags: 1 }).forEach (doc)->
    #             if doc._id isnt docId
    #                 idArrayWithTag.push doc._id
    #         matchObject[tag] = idArrayWithTag
    #     arrays = _.values matchObject
    #     flattenedArrays = _.flatten arrays
    #     countObject = {}
    #     for id in flattenedArrays
    #         if countObject[id]? then countObject[id]++ else countObject[id]=1
    #     # console.log countObject
    #     result = []
    #     for id, count of countObject
    #         comparedDoc = Docs.findOne(id)
    #         returnedObject = {}
    #         returnedObject.docId = id
    #         returnedObject.tags = comparedDoc.tags
    #         returnedObject.username = comparedDoc.username
    #         returnedObject.intersectionTags = _.intersection tags, comparedDoc.tags
    #         returnedObject.intersectionTagsCount = returnedObject.intersectionTags.length
    #         result.push returnedObject

    #     result = _.sortBy(result, 'intersectionTagsCount').reverse()
    #     result = result[0..5]
    #     Docs.update docId,
    #         $set: topDocMatches: result

    #     # console.log result
    #     return result

    # matchTwoUsersAuthoredCloud: (uId)->
    #     username = Meteor.users.findOne(uId).username
    #     match = {}
    #     match.authorId = $in: [Meteor.userId(), uId]

    #     userMatchAuthoredCloud = Docs.aggregate [
    #         { $match: match }
    #         { $project: tags: 1 }
    #         { $unwind: '$tags' }
    #         { $group: _id: '$tags', count: $sum: 1 }
    #         { $sort: count: -1, _id: 1 }
    #         { $limit: 50 }
    #         { $project: _id: 0, name: '$_id', count: 1 }
    #         ]
    #     # authoredList = (tag.name for tag in userMatchAuthoredCloud)
    #     Meteor.users.update Meteor.userId(),
    #         $addToSet:
    #             authoredCloudMatches:
    #                 uId: uId
    #                 username: username
    #                 userMatchAuthoredCloud: userMatchAuthoredCloud

    # matchTwoUsersUpvotedCloud: (uId)->
    #     username = Meteor.users.findOne(uId).username
    #     match = {}
    #     match.upVoters = $in: [Meteor.userId(), uId]

    #     userMatchUpvotedCloud = Docs.aggregate [
    #         { $match: match }
    #         { $project: tags: 1 }
    #         { $unwind: '$tags' }
    #         { $group: _id: '$tags', count: $sum: 1 }
    #         { $sort: count: -1, _id: 1 }
    #         { $limit: 50 }
    #         { $project: _id: 0, name: '$_id', count: 1 }
    #         ]
    #     Meteor.users.update Meteor.userId(),
    #         $addToSet:
    #             upVotedCloudMatches:
    #                 uId: uId
    #                 username: username
    #                 userMatchUpvotedCloud: userMatchUpvotedCloud

