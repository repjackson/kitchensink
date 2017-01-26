FlowRouter.route '/edit-slides', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_slides'


FlowRouter.route '/slide/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_slide'

FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'home'


