@selected_tags = new ReactiveArray []

Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe 'tags', selected_tags.array()



Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'

Accounts.ui.config
    dropdownClasses: 'simple'
    

Template.cloud.helpers
    all_tags: ->
        user_count = Meteor.users.find().count()
        if 0 < user_count < 3 then Tags.find({ count: $lt: user_count }, {limit:20}) else Tags.find({}, limit:20)
        # Tags.find()

    selected_tags: -> selected_tags.list()


Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selected_tags.array())


Template.people.helpers
    people: -> 
        Meteor.users.find { _id: $ne: Meteor.userId() }, 
            sort:
                tag_count: 1
            limit: 10

    tag_class: -> if @valueOf() in selected_tags.array() then 'primary' else ''

Template.cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()


