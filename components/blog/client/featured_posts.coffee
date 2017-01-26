Template.featured_posts.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'featured_posts'


Template.featured_posts.helpers
    featured_posts: -> Docs.find {
            type: 'post'
            featured: true
        },
            sort: publish_date: -1
            limit: 4
            
            
Template.featured_posts.events
    # 'click .featured_post_title': ->
    #     selected_tags.clear()
    #     for tag in @tags
    #         selected_tags.push tag
    #     FlowRouter.go '/posts'

