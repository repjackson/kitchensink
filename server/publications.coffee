Meteor.publish 'doc', (id)-> Docs.find id


Meteor.publish 'myDocs', (selectedTags)->

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    match.authorId = @userId

    Docs.find match,
        limit: 20
        sort:
            timestamp: -1
            tagCount: 1

Meteor.publish 'personWants', (id)->
    cursor = Docs.find {authorId: id},
        fields:
            tags: 1
    console.log 'person Wants', cursor.count()
    cursor

Meteor.publish 'person', (id)->
    Meteor.users.find id,
        fields:
            tags: 1
            username: 1
            authoredCloud: 1
            authoredList: 1

Meteor.publish 'me', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            username: 1
            authoredCloud: 1
            authoredList: 1

Meteor.publish 'people', (selectedUserTags)->
    self = @
    # console.log selectedUserTags
    match = {}
    if selectedUserTags and selectedUserTags.length > 0 then match.authoredList = $all: selectedUserTags

    cursor = Meteor.users.find match,
        fields:
            tags: 1
            username: 1
            authoredCloud: 1
            authoredList: 1
    # console.log cursor.count()
    return cursor


Meteor.publish 'docs', (selectedTags, authorId)->

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    if authorId then match.authorId = authorId

    Docs.find match,
        limit: 10
        sort:
            timestamp: -1
            tagCount: 1


Meteor.publish 'userTags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags

    userCloud = Meteor.users.aggregate [
        { $match: match }
        { $project: tagList: 1 }
        { $unwind: '$tagList' }
        { $group: _id: '$tagList', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    userCloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()

Meteor.publish 'docTags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    match.authorId = $ne: @userId

    docCloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    docCloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i


    self.ready()

#Meteor.publish 'authored_intersection_tags', (authorId)->
    #author_list = Meteor.users.findOne(authorId).authored_list
    #author_tags = Meteor.users.findOne(authorId).authored_cloud
#
    #your_list = Meteor.user().authored_list
    #your_tags = Meteor.user().authored_cloud
#
    #list_intersection = _.intersection(author_list, your_list)
#
    #intersection_tags = []
    #for tag in list_intersection
        #author_count = author_tags.tag.count
        #your_count = your_tags.tag.count
        #lower_value = Meth.min(author_count, your_count)
        #cloud_object = name: tag, count: lower_value
        #intersection_tags.push cloud_object
#
    #console.log intersection_tags
#
    #intersection_tags.forEach (tag) ->
        #self.added 'authored_intersection_tags', Random.id(),
            #name: tag.name
            #count: tag.count
#
    #self.ready()


Meteor.publish 'myTags', (selectedTags)->
    self = @

    match = {}
    if selectedTags.length > 0 then match.tags = $all: selectedTags
    match.authorId = @userId

    myTagCloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: '$tags' }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selectedTags }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    myTagCloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()