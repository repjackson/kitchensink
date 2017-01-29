if Meteor.isClient
    Template.upvoted_cloud.onCreated ->
        @autorun -> Meteor.subscribe 'upvoted_cloud'


if Meteor.isServer
    Meteor.publish 'upvoted_cloud', ->
        Meteor.users.find @userId,
            fields:
                upvoted_cloud: 1
                upvoted_list: 1
