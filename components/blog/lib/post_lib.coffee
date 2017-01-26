FlowRouter.route '/posts', action: ->
    BlazeLayout.render 'layout', 
        main: 'posts'

FlowRouter.route '/post/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_post'

FlowRouter.route '/post/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'post_page'


