Template.person.onCreated ->
    Meteor.subscribe 'person', @_id

Template.person.helpers
    isUser: -> @_id is Meteor.userId()

    myTags: ->
        _.findWhere(Meteor.user().userTags, uId: @_id)?.tags

    userTagClass: ->
        if @name in selectedUserTags.array() then 'primary' else 'basic'

    hasTagged: ->
        if @taggers and Meteor.userId() in @taggers then true else false

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

    'keyup .addTag': (e,t)->
        tag = t.find('.addTag').value.toLowerCase()
        switch e.which
            when 13
                if tag.length > 0
                    Meteor.call 'addTag', @_id, tag
                    $('.addTag').val('')

    'click .tagUser': ->
        Meteor.call 'tagUser', @_id

    'click .removeMyTag': ->
        # console.log Template.currentData()._id
        Meteor.call 'removeUserTag', Template.currentData()._id, @valueOf()