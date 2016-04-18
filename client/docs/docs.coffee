# Template.docs.onCreated ->
#     @autorun -> Meteor.subscribe('docs', selectedTags.array(), selectedUsernames.array(), Session.get('view'))

# Template.docs.helpers
#     # docs: -> Docs.find({}, limit: 1)
#     docs: -> Docs.find()


# Template.view.onCreated ->
#     Meteor.subscribe 'person', @data.authorId

# Template.view.helpers
#     isAuthor: -> @authorId is Meteor.userId()


#     when: -> moment(@timestamp).fromNow()

#     docTagClass: ->
#         result = ''
#         if @valueOf() in selectedTags.array() then result += ' primary' else result += ' basic'
#         if Meteor.userId() in Template.parentData(1).upVoters then result += ' green'
#         else if Meteor.userId() in Template.parentData(1).downVoters then result += ' red'
#         return result

#     upVotedMatchCloud: ->
#         myUpVotedCloud = Meteor.user().upvotedCloud
#         myUpVotedList = Meteor.user().upvotedList
#         # console.log 'myUpVotedCloud', myUpVotedCloud
#         # console.log @
#         otherUser = Meteor.users.findOne @authorId
#         otherUpVotedCloud = otherUser?.upvotedCloud
#         otherUpVotedList = otherUser?.upvotedList
#         # console.log 'otherCloud', otherUpVotedCloud
#         intersection = _.intersection(myUpVotedList, otherUpVotedList)
#         intersectionCloud = []
#         totalCount = 0
#         for tag in intersection
#             myTagObject = _.findWhere myUpVotedCloud, name: tag
#             hisTagObject = _.findWhere otherUpVotedCloud, name: tag
#             # console.log hisTagObject.count
#             min = Math.min(myTagObject.count, hisTagObject.count)
#             totalCount += min
#             intersectionCloud.push
#                 tag: tag
#                 min: min
#         sortedCloud = _.sortBy(intersectionCloud, 'min').reverse()
#         result = {}
#         result.cloud = sortedCloud
#         result.totalCount = totalCount
#         return result

#     authorFilterButtonClass: ->
#         if @username in selectedUsernames.array() then 'primary' else 'basic'


#     author: -> Meteor.users.findOne(@authorId)

#     currentUserDonations: ->
#         if @donators and Meteor.userId() in @donators
#             result = _.find @donations, (donation)->
#                 donation.user is Meteor.userId()
#             result.amount
#         else return 0


# Template.view.events
#     'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

#     'click .cloneDoc': ->
#         id = Docs.insert
#             tags: @tags
#         FlowRouter.go "/edit/#{id}"

#     'click .docTag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()


#     'click .deleteDoc': ->
#         if confirm 'Delete?'
#             Meteor.call 'deleteDoc', @_id

#     'click .authorFilterButton': ->
#         if @username in selectedUsernames.array() then selectedUsernames.remove @username else selectedUsernames.push @username

