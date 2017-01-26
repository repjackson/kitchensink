Template.posts.onCreated ->
    @autorun -> Meteor.subscribe('selected_posts', selected_tags.array())

Template.posts.onRendered ->
    $('#blog_slider').layerSlider
        autoStart: true


Template.posts.helpers
    posts: -> 
        Docs.find {
            type: 'post'
            },
            sort:
                publish_date: -1
            limit: 5
            
Template.posts.events
    'click #add_post': ->
        id = Docs.insert
            type: 'post'
        FlowRouter.go "/post/edit/#{id}"




Template.post.helpers
    tag_class: -> if @valueOf() in selected_tags.array() then 'red' else 'basic'

    can_edit: -> @author_id is Meteor.userId()

    
Template.post_item.helpers
    tag_class: -> if @valueOf() in selected_tags.array() then 'red' else 'basic'

    can_edit: -> @author_id is Meteor.userId()

    


Template.post.events
    'click .post_tag': ->
        if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()

    'click .edit_post': ->
        FlowRouter.go "/post/edit/#{@_id}"
