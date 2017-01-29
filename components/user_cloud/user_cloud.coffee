@User_tags = new Meteor.Collection 'user_tags'



if Meteor.isClient
    @selected_user_tags = new ReactiveArray []
    
    Template.user_cloud.onCreated ->
        @autorun -> Meteor.subscribe 'user_tags', selected_user_tags.array()
    


    Template.user_cloud.helpers
        all_user_tags: ->
            user_count = Meteor.users.find().count()
            if 0 < user_count < 3 then User_tags.find({ count: $lt: user_count }, {limit:20}) else User_tags.find({}, limit:20)
            # User_tags.find()
    
        selected_user_tags: -> selected_user_tags.list()
    
        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'big'
                when @index <= 10 then 'large'
                when @index <= 15 then ''
                when @index <= 20 then 'small'
                when @index <= 25 then 'tiny'
            return button_class


    Template.user_cloud.events
        'click .select_tag': -> selected_user_tags.push @name
        'click .unselect_tag': -> selected_user_tags.remove @valueOf()
        'click #clear_tags': -> selected_user_tags.clear()






if Meteor.isServer
    Meteor.publish 'user_tags', (selected_user_tags)->
        self = @
        match = {}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
    
        user_cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_user_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        user_cloud.forEach (tag, i) ->
            self.added 'user_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
    
        self.ready()
        
