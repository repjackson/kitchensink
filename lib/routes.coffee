FlowRouter.route '/people',
    name: 'people'
    action: ->
        BlazeLayout.render 'layout', main: 'people'

FlowRouter.route '/docs',
    name: 'docs'
    action: ->
        BlazeLayout.render 'layout', main: 'docs'

FlowRouter.route '/profile',
    name: 'profile'
    action: ->
        BlazeLayout.render 'layout', main: 'profile'

FlowRouter.route '/',
  triggersEnter: [ (context, redirect) ->
    redirect '/people'
    return
 ]
  action: (_params) ->
    throw new Error('this should not get called')
    return
