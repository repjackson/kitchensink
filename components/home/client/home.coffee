# Template.view_slider.helpers 
#     gallery_images: ->
#         Docs.find()



# Template.view_slider.onRendered ->
#     # console.log 'Initial Swiper'
#     # swiper = new Swiper('.swiper-container',
#     #     resistance: '100%'
#     #     createPagination: false
#     #     loop: false)
#     # console.log swiper
#     # swiper.reInit()
#     return





            
Template.rockstar_members.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'rockstar_members'


Template.rockstar_members.helpers
    rockstar_members: -> 
        Meteor.users.find {}, 
            limit: 4

