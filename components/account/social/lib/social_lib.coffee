FlowRouter.route '/account/social/', action: (params) ->
    BlazeLayout.render 'layout',
        sub_nav: 'account_nav'
        main: 'social'
