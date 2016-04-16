FlowRouter.route '/leaderboard', action: (params) ->
    BlazeLayout.render 'layout', main: 'leaderboard'

FlowRouter.route '/importers', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'importerList'

FlowRouter.route '/importers/:iId', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'importerView'

FlowRouter.route '/bulk', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'bulk'
FlowRouter.route '/marketplace', action: (params) ->
    Session.set('view', 'marketplace')
    BlazeLayout.render 'layout', main: 'home'


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

FlowRouter.route '/unvoted', action: (params) ->
    Session.set('view', 'unvoted')
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'docCloud'
        main: 'docs'

FlowRouter.route '/profile', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'

FlowRouter.route '/marketplace', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'marketplace'

