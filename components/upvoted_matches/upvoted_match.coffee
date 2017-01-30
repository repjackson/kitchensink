if Meteor.isClient
    Template.upvoted_matches.helpers
    
        upvoted_match_list: ->
            my_upvoted_list = Meteor.user().upvoted_list
            other_user = Meteor.users.findOne @_id
            other_upvoted_list = other_user.upvoted_list
            intersection = _.intersection(my_upvoted_list, other_upvoted_list)
            return intersection
    
        upvoted_match_cloud: ->
            my_upvoted_cloud = Meteor.user().upvoted_cloud
            my_upvoted_list = Meteor.user().upvoted_list
            # console.log 'my_upvoted_cloud', my_upvoted_cloud
            other_user = Meteor.users.findOne @_id
            other_upvoted_cloud = other_user.upvoted_cloud
            other_upvoted_list = other_user.upvoted_list
            # console.log 'otherCloud', other_upvoted_cloud
            intersection = _.intersection(my_upvoted_list, other_upvoted_list)
            intersection_cloud = []
            total_count = 0
            for tag in intersection
                myTagObject = _.findWhere my_upvoted_cloud, name: tag
                hisTagObject = _.findWhere other_upvoted_cloud, name: tag
                # console.log hisTagObject.count
                min = Math.min(myTagObject.count, hisTagObject.count)
                total_count += min
                intersection_cloud.push
                    tag: tag
                    min: min
            sorted_cloud = _.sortBy(intersection_cloud, 'min').reverse()
            result = {}
            result.cloud = sorted_cloud
            result.total_count = total_count
            return result


    Template.upvoted_matches.events
        'click .match_two_users_upvoted_cloud': ->
            Meteor.call 'match_two_users_upvoted_cloud', @_id, ->