Meteor.publish 'tags', (selected_tags, selected_active_location_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if selected_active_location_tags.length > 0 then match.active_location = $in: [selected_active_location_tags]
    match._id = $ne: @userId

    cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()
    
    
Meteor.publish 'location_tags', (selected_tags, selected_active_location_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match._id = $ne: @userId

    Location_tags.find()

Meteor.publish 'me', ()-> 
    Meteor.users.find @userId,
        fields:
            username: 1
            tags: 1
            contact: 1
            location_tags: 1
            active_location: 1


            
Meteor.publish 'person', (person_id)-> 
    Meteor.users.find person_id,
        fields: 
            username: 1
            tags: 1
            location_tags: 1
            active_location: 1


Meteor.publish 'people', (selected_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    Meteor.users.find match,
        fields:
            username: 1
            tags: 1
            active_location: 1


Meteor.publish 'active_locations', (selected_tags, selected_active_location_tags)->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if selected_active_location_tags.length > 0 then match.active_location = selected_active_location_tags
    if selected_active_location_tags.length > 0 then match.active_location = $set: true

    # console.log 'match', match

    cloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "active_location": 1 }
        # { $unwind: "$active_location" }
        { $group: _id: "$active_location", count: $sum: 1 }
        { $match: _id: $nin: selected_active_location_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    # console.log cloud    
        
    cloud.forEach (active_location, i) ->
        self.added 'active_locations', Random.id(),
            name: active_location.name
            count: active_location.count
            index: i

    self.ready()
    