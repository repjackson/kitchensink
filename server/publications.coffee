Meteor.publish 'person', (id)-> Meteor.users.find id


Meteor.publish 'people', (selectedTraits)->
    self = @
    match = {}
    if selectedTraits and selectedTraits.length > 0 then match.traits = $all: selectedTraits

    Meteor.users.find match


Meteor.publish 'traits', (selectedTraits)->
    self = @
    match = {}
    if selectedTraits.length > 0 then match.traits = $all: selectedTraits

    traitCloud = Meteor.users.aggregate [
        { $match: match }
        { $project: "traits": 1 }
        { $unwind: "$traits" }
        { $group: _id: "$traits", count: $sum: 1 }
        { $match: _id: $nin: selectedTraits }
        { $sort: count: -1, _id: 1 }
        { $limit: 50 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]

    traitCloud.forEach (trait, i) ->
        self.added 'traits', Random.id(),
            name: trait.name
            count: trait.count
            index: i

    self.ready()

