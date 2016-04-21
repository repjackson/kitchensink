Template.person.onCreated ->
    # Meteor.subscribe 'person', @data._id
    # Meteor.subscribe 'personWants', @data._id
    @autorun -> Meteor.subscribe 'docs', selectedUserTags.array()
    # if @data._id then console.log 'dataId', @data._id

Template.person.helpers
    isUser: -> @_id is Meteor.userId()

    personWants: ->
        Docs.find( authorId: @_id )
        # Docs.find()

    userTagClass: ->
        if @name in selectedUserTags.array() then 'primary' else 'basic'

    userDocTagClass: ->
        if @valueOf() in selectedUserTags.array() then 'primary' else 'basic'


    # upVotedMatchCloud: ->
    #     myUpVotedCloud = Meteor.user().upvotedCloud
    #     myUpVotedList = Meteor.user().upvotedList
    #     # console.log 'myUpVotedCloud', myUpVotedCloud
    #     otherUser = Meteor.users.findOne @authorId
    #     otherUpVotedCloud = otherUser.upvotedCloud
    #     otherUpVotedList = otherUser.upvotedList
    #     # console.log 'otherCloud', otherUpVotedCloud
    #     intersection = _.intersection(myUpVotedList, otherUpVotedList)
    #     intersectionCloud = []
    #     totalCount = 0
    #     for tag in intersection
    #         myTagObject = _.findWhere myUpVotedCloud, name: tag
    #         hisTagObject = _.findWhere otherUpVotedCloud, name: tag
    #         # console.log hisTagObject.count
    #         min = Math.min(myTagObject.count, hisTagObject.count)
    #         totalCount += min
    #         intersectionCloud.push
    #             tag: tag
    #             min: min
    #     sortedCloud = _.sortBy(intersectionCloud, 'min').reverse()
    #     result = {}
    #     result.cloud = sortedCloud
    #     result.totalCount = totalCount
    #     return result

Template.person.events
    'click .userTag': ->
        if @name in selectedUserTags.array() then selectedUserTags.remove @name else selectedUserTags.push @name
