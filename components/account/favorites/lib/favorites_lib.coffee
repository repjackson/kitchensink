FlowRouter.route '/account/favorites/', action: (params) ->
    BlazeLayout.render 'layout',
        sub_nav: 'account_nav'
        main: 'favorites'
