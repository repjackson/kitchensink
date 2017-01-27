@selected_conversation_tags = new ReactiveArray []


Template.conversation_cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags', selected_conversation_tags.array(), 'conversation')

Template.conversation_cloud.helpers
    conversation_tags: ->
        # userCount = Meteor.users.find().count()
        # if 0 < userCount < 3 then tags.find { count: $lt: userCount } else tags.find()
        Tags.find()

    conversation_tag_class: ->
        buttonClass = switch
            when @index <= 10 then 'big'
            when @index <= 20 then 'large'
            when @index <= 30 then ''
            when @index <= 40 then 'small'
            when @index <= 50 then 'tiny'
        return buttonClass

    selected_conversation_tags: -> selected_conversation_tags.list()
    

Template.conversation_cloud.events
    'click .select_tag': -> selected_conversation_tags.push @name
    'click .unselect_tag': -> selected_conversation_tags.remove @valueOf()
    'click #clear_tags': -> selected_conversation_tags.clear()
    
    'click #create_conversation': ->
        id = Docs.insert 
            type: 'conversation'
            participant_ids: [Meteor.userId()]
        FlowRouter.go "/conversation/#{id}"

