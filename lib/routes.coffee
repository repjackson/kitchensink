FlowRouter.route '/people', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'userCloud'
        main: 'people'

FlowRouter.route '/edit/:docId', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit'


FlowRouter.route '/', action: (params) ->
    Session.set('view', 'all')
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'docCloud'
        main: 'docs'


FlowRouter.route '/mine', action: (params) ->
    Session.set('view', 'mine')
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'docCloud'
        main: 'docs'


FlowRouter.route '/profile', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'

