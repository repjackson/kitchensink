FlowRouter.route '/',
    name: 'people'
    action: ->
        BlazeLayout.render 'layout', main: 'people'


FlowRouter.route '/profile',
    name: 'profile'
    action: ->
        BlazeLayout.render 'layout', main: 'profile'


FlowRouter.route '/messages', action: (params) ->
    BlazeLayout.render 'layout', main: 'messages'
