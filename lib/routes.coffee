FlowRouter.route '/people',
    name: 'people'
    action: ->
        BlazeLayout.render 'layout', main: 'people'

FlowRouter.route '/docs',
    name: 'docs'
    action: ->
        BlazeLayout.render 'layout', main: 'docs'

FlowRouter.route '/docs/edit/:doc_id',
    name: 'edit'
    action: ->
        BlazeLayout.render 'layout', main: 'edit'

FlowRouter.route '/profile',
    name: 'profile'
    action: ->
        BlazeLayout.render 'layout', main: 'profile'

FlowRouter.route '/exchange',
    name: 'exchange'
    action: ->
        BlazeLayout.render 'layout', main: 'exchange'

FlowRouter.route '/',
  triggersEnter: [ (context, redirect) ->
    redirect '/docs'
    return
 ]
  action: (_params) ->
    throw new Error('this should not get called')
    return


FlowRouter.route '/bulk', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout',
        # nav: 'nav'
        main: 'bulk'
        
FlowRouter.route '/marketplace', action: (params) ->
    Session.set('view', 'marketplace')
    BlazeLayout.render 'layout', main: 'home'


FlowRouter.route '/leaderboard', action: (params) ->
    BlazeLayout.render 'layout', main: 'leaderboard'


FlowRouter.route '/messages', action: (params) ->
    BlazeLayout.render 'layout', main: 'messages'
