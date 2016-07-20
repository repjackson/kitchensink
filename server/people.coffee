Accounts.onCreateUser (options, user) ->
    user.people_you_like = []
    user


            
Meteor.publish 'self_doc', ->
    # console.log 'publish self_doc'
    Docs.find
        recipient_id: @userId
        author_id: @userId


Meteor.publish 'review_doc', (recipient_id)->
    # console.log 'publish self_doc'
    Docs.find
        recipient_id: recipient_id
        author_id: @userId




Meteor.methods
    # generate_person_cloud: (user_id)->
    #     cloud = Docs.aggregate [
    #         { $match: recipient_id: user_id }
    #         { $project: tags: 1 }
    #         { $unwind: '$tags' }
    #         { $group: _id: '$tags', count: $sum: 1 }
    #         { $sort: count: -1, _id: 1 }
    #         { $limit: 20 }
    #         { $project: _id: 0, name: '$_id', count: 1 }
    #         ]
            
    #     list = (tag.name for tag in cloud)
    #     Meteor.users.update user_id,
    #         $set:
    #             cloud: cloud
    #             list: list

