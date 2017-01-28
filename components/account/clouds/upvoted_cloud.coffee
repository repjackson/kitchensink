if Meteor.isClient
    Template.upvoted_cloud.onCreated ->
        @autorun -> Meteor.subscribe 'my_clouds'


if Meteor.isServer
    Meteor.publish 'my_clouds', ->
        Meteor.users.find @userId,
            fields:
                upvoted_cloud: 1
                downvoted_cloud: 1
                authored_cloud: 1
                
                
                