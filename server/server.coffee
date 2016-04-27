Events.allow
    update: (userId, doc, fieldNames, modifier) -> doc.hostId is Meteor.userId()
    remove: (userId, doc)-> doc.hostId is userId

Conversations.allow
    update: (userId, doc, fieldNames, modifier) -> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is userId




Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            tags: 1
            profile: 1
            username: 1

Meteor.publish 'usernames', ->
    Meteor.users.find {},
        fields:
            username: 1

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            profile: 1
            username: 1

Meteor.publish 'sent_messages', ->
    Messages.find
        authorId: @userId


Meteor.publish 'conversationMessages', (conversationId) ->
    Messages.find
        conversationId: conversationId


Meteor.publish 'eventMessages', (eventId) ->
    Messages.find
        eventId: eventId

Meteor.publish 'received_messages', ->
    Messages.find
        recipientId: @userId



Meteor.publish 'people', (selectedtags)->
    self = @
    match = {}
    if selectedtags and selectedtags.length > 0 then match.tags = $all: selectedtags

    Meteor.users.find match,
        fields:
            tags: 1
            profile: 1
            username: 1

Meteor.publish 'conversations', (selectedtags)->
    self = @
    match = {}
    if selectedtags and selectedtags.length > 0 then match.tags = $all: selectedtags

    Conversations.find match,
        fields:
            tags: 1
            authorId: 1
            participantIds: 1

Meteor.publish 'events', (selectedtags)->
    self = @
    match = {}
    if selectedtags and selectedtags.length > 0 then match.tags = $all: selectedtags

    Events.find match,
        fields:
            tags: 1
            attendeeIds: 1
            hostId: 1
            datearray: 1
            dateTime: 1


Meteor.publish 'people_tags', (selectedtags)->
    self = @
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags
    # match.authorId = $ne: @userId

    tagCloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    tagCloud.forEach (tag, i) ->
        self.added 'people_tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()


Meteor.publish 'conversation_tags', (selectedtags)->
    self = @
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags
    # match.authorId = $ne: @userId

    tagCloud = Conversations.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    tagCloud.forEach (tag, i) ->
        self.added 'conversation_tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

Meteor.publish 'event_tags', (selectedtags)->
    self = @
    match = {}
    if selectedtags.length > 0 then match.tags = $all: selectedtags
    # match.authorId = $ne: @userId

    tagCloud = Events.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selectedtags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    tagCloud.forEach (tag, i) ->
        self.added 'event_tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

