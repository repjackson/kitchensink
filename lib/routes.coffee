FlowRouter.route '/people', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'userCloud'
        main: 'people'

FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'

