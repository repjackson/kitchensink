FlowRouter.route '/admin/add_user', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'add_user'
        