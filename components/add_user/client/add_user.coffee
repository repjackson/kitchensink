# Template.users.onCreated ->
#     self = @
#     self.autorun ->
#         self.subscribe 'hub_users'


Template.users.helpers
    hub_users: -> 
        Meteor.users.find {}

Template.add_user.events
    'click #submit_new_user': ->
        name = $('#name').val()
        email = $('#email').val()
        bio = $('#bio').val()
        