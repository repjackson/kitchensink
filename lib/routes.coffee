FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'userCloud'
        main: 'people'

FlowRouter.route '/profile', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'

