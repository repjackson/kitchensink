if Meteor.isClient
    Template.upvoted_match.helpers
    
        upvoted_match_list: ->
            my_upvoted_list = Meteor.user().upvoted_list
            other_user = Meteor.users.findOne @author_id
            other_upvoted_list = other_user.upvoted_list
            intersection = _.intersection(my_upvoted_list, other_upvoted_list)
            return intersection
    
        upvoted_match_cloud: ->
            my_upvoted_cloud = Meteor.user().upvoted_cloud
            my_upvoted_list = Meteor.user().upvoted_list
            # console.log 'my_upvoted_cloud', my_upvoted_cloud
            other_user = Meteor.users.findOne @author_id
            otherupvoted_cloud = other_user.upvoted_cloud
            other_upvoted_list = other_user.upvoted_list
            # console.log 'otherCloud', otherupvoted_cloud
            intersection = _.intersection(my_upvoted_list, other_upvoted_list)
            intersection_cloud = []
            total_count = 0
            for tag in intersection
                myTagObject = _.findWhere my_upvoted_cloud, name: tag
                hisTagObject = _.findWhere otherupvoted_cloud, name: tag
                # console.log hisTagObject.count
                min = Math.min(myTagObject.count, hisTagObject.count)
                total_count += min
                intersection_cloud.push
                    tag: tag
                    min: min
            sortedCloud = _.sortBy(intersection_cloud, 'min').reverse()
            result = {}
            result.cloud = sortedCloud
            result.total_count = total_count
            return result
