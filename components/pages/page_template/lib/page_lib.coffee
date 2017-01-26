FlowRouter.route '/page/edit/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit_page'

FlowRouter.route '/page/view/:doc_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'view_page'


