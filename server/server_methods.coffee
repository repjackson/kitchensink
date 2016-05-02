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

