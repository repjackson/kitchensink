

Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'

Accounts.ui.config
    dropdownClasses: 'simple'
    

$.cloudinary.config
    cloud_name:"facet"

Template.registerHelper 'is_author', () ->  Meteor.userId() is @author_id

Template.registerHelper 'can_edit', () ->  Meteor.userId() is @author_id or Roles.userIsInRole(Meteor.userId(), 'admin')

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()


Template.registerHelper 'is_dev', () -> Meteor.isDevelopment
