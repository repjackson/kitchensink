Template.people.onCreated ->
    @autorun -> Meteor.subscribe('filtered_people', selectedUserTags.array())

Template.people.helpers
    # people: -> Meteor.users.find({ _id: $ne: Meteor.userId() })
    people: -> Meteor.users.find()

Template.person.onCreated ->
    Meteor.subscribe 'person', @_id

Template.person.helpers
    isUser: -> @_id is Meteor.userId()

    myTags: ->
        _.findWhere(Meteor.user().userTags, uId: @_id)?.tags

    userTagClass: ->
        if @valueOf() in selectedUserTags.array() then 'primary' else 'basic'

    hasTagged: ->
        if @taggers and Meteor.userId() in @taggers then true else false

    upVotedMatchCloud: ->
        my_upvoted_cloud = Meteor.user().upvoted_cloud
        my_upvoted_list = Meteor.user().upvoted_list
        otherUser = Meteor.users.findOne @authorId
        other_upvoted_cloud = otherUser?.upvoted_cloud
        other_upvoted_list = otherUser?.upvoted_list
        intersection = _.intersection(my_upvoted_list, other_upvoted_list)
        intersectionCloud = []
        totalCount = 0
        for tag in intersection
            myTagObject = _.findWhere my_upvoted_cloud, name: tag
            hisTagObject = _.findWhere other_upvoted_cloud, name: tag
            min = Math.min(myTagObject.count, hisTagObject.count)
            totalCount += min
            intersectionCloud.push
                tag: tag
                min: min
        sortedCloud = _.sortBy(intersectionCloud, 'min').reverse()
        result = {}
        result.cloud = sortedCloud
        result.totalCount = totalCount
        return result

Template.person.events
    'click .userTag': ->
        if @valueOf() in selectedUserTags.array() then selectedUserTags.remove @valueOf() else selectedUserTags.push @valueOf()

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