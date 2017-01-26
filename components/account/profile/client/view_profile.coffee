Template.view_profile.onCreated ->
    @autorun -> Meteor.subscribe('user_profile', FlowRouter.getParam('user_id'))

Template.view_profile.helpers
    person: -> Meteor.users.findOne(FlowRouter.getParam('user_id'))

    can_edit: -> FlowRouter.getParam('user_id') is Meteor.userId()


Template.view_profile.events
    'click .tag': ->
        if @valueOf() in selected_people_tags.array() then selected_people_tags.remove @valueOf() else selected_people_tags.push @valueOf()

