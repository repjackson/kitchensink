Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'me'


Template.nav.helpers
    selected_tags: -> selected_tags.array()



Template.nav.events
    'click #home': -> selected_tags.clear()
