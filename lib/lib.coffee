@Tags = new Meteor.Collection 'tags'


FlowRouter.route '/profile/', action: (params) ->
    BlazeLayout.render 'layout',
        # sub_nav: 'account_nav'
        main: 'profile'



FlowRouter.route '/',
    name: 'home'
    action: ->
        BlazeLayout.render 'layout', 
            cloud: 'cloud'
            main: 'people'
