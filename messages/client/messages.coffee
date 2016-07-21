Template.messages.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'inbox'
        self.subscribe 'outbox'
        self.subscribe 'people', []

Template.messages.helpers
    inbox_messages: -> 
        Messages.find
            recipient_id: Meteor.userId()
    
    outbox_messages: -> 
        Messages.find
            author_id: Meteor.userId()

    settings: ->
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    # token: ''
                    collection: Meteor.users
                    field: 'username'
                    matchAll: true
                    template: Template.user_lookup
                }
            ]
        }


Template.messages.events
    'autocompleteselect #recipient': (event, template, doc) ->
        # console.log 'selected ', doc
        # selected_doc_tags.push doc.name
        # $('#recipient').val ''

    'keyup #message_text': (e,t)->
        e.preventDefault
        switch e.which
            when 13
                message = $('#message_text').val().toLowerCase()
                recipient = $('#recipient').val()
                if message.length > 0
                    split_tags = message.match(/\S+/g)
                    $('#message_text').val('')
                    Meteor.call 'send_message', recipient, message, split_tags
