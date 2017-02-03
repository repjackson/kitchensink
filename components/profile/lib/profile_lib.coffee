FlowRouter.route '/account/profile/edit/:user_id?', action: (params) ->
    if not params.user_id then FlowRouter.setParams(user_id: Meteor.userId())
    BlazeLayout.render 'layout',
        sub_nav: 'account_nav'
        main: 'edit_profile'

FlowRouter.route '/account/profile/view/:user_id?', action: (params) ->
    if not params.user_id then params.user_id = Meteor.userId()
    BlazeLayout.render 'layout',
        main: 'view_profile'

