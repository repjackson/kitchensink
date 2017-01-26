@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    # doc.tag = []
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tag_count = doc.tags?.length
), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()







if Meteor.isServer
    Docs.allow
        insert: (userId, doc) -> doc.author_id is userId
        update: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> doc.author_id is userId or Roles.userIsInRole(userId, 'admin')

    
    
    
    
    
    
    
    Meteor.publish 'docs', (selected_tags, filter)->
    
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.type = filter
    
        Docs.find match,
            limit: 20
            
    
    Meteor.publish 'doc', (id)->
        Docs.find id
    
    
    Meteor.publish 'featured_docs', (filter)->
        match = {}
        match.featured = true
        match.type = filter
        
        Docs.find match, limit: 3
    
    
    Meteor.publish 'tags', (selected_tags, filter)->
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.type = filter
    
        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
    
        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud
    
        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
    
