Meteor.publish 'tags', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.list = $all: selected_tags
    match._id = $ne: @userId

    cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "list": 1 }
        { $unwind: "$list" }
        { $group: _id: "$list", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
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
    
    
Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields:
            username: 1
            tags: 1
            contact: 1
            picture: 1
            cloud: 1
            list: 1
            friends: 1

Meteor.publish 'friended_people', ()-> 
    me = Meteor.users.findOne @userId
    
    Meteor.users.find friends: $in: [@userId],
        fields:
            username: 1
            tags: 1
            contact: 1
            picture: 1
            friends: 1
            cloud: 1
            list: 1



            
Meteor.publish 'person', (person_id)-> 
    Meteor.users.find person_id,
        fields: 
            username: 1
            tags: 1
            friends: 1
            cloud: 1
            list: 1



Meteor.publish 'people', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.list = $all: selected_tags

    Meteor.users.find match,
        fields:
            username: 1
            tags: 1
            picture: 1
            friends: 1
            cloud: 1
            list: 1
            
            
Meteor.publish 'my_review_of_user', (user_id)->
    Docs.find 
        author_id: @userId
        recipient_id: user_id


    
Accounts.onCreateUser (options, user) ->
    if user.services.google
        user.username = user.services.google.name
        user.contact = user.services.google.email
        user.picture = user.services.google.picture
    
    user
    
    
    
Meteor.methods
    generate_person_cloud: (user_id)->
        cloud = Docs.aggregate [
            { $match: recipient_id: user_id }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
            
        list = (tag.name for tag in cloud)
        Meteor.users.update user_id,
            $set:
                cloud: cloud
                list: list


    tag_user: (recipient_id, tag)->
        Docs.update { author_id: Meteor.userId(), recipient_id: recipient_id},
            { $addToSet: tags: tag }
            , upsert: true
                
        Meteor.call 'generate_person_cloud', recipient_id
        
        
        
    remove_review_tag: (recipient_id, tag) ->
        Docs.update { author_id: Meteor.userId(), recipient_id: recipient_id},
            { $pull: tags: tag }

        Meteor.call 'generate_person_cloud', recipient_id

    
