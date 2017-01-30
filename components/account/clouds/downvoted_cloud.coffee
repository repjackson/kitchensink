if Meteor.isClient
    Template.downvoted_cloud.onCreated ->
        @autorun -> Meteor.subscribe 'downvoted_cloud'


if Meteor.isServer
    Meteor.publish 'downvoted_cloud', ->
        Meteor.users.find @userId,
            fields:
                downvoted_cloud: 1
                downvoted_list: 1
                
                