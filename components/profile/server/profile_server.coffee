Meteor.publish 'my_profile', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            profile: 1
            username: 1
            published: 1
            image_id: 1


Meteor.publish 'user_profile', (id)->
    Meteor.users.find id,
        fields:
            tags: 1
            profile: 1
            username: 1
            published: 1
            image_id: 1
