Template.users.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'hub_users'


Template.users.helpers
    hub_users: -> 
        Meteor.users.find {}


