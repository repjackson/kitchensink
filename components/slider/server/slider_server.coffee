
Meteor.publish 'slides', ->
    Docs.find 
        tags: $in: ['slide']
        type: 'slide'
