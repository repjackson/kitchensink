if Meteor.isClient
    Template.nav.events
        'click #logout': -> AccountsTemplates.logout()
