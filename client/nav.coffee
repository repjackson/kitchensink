Template.nav.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'me'


Template.nav.helpers
    user_counter: -> Meteor.users.find().count()

    user: -> Meteor.user()

    tagsettings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Tags
                field: 'name'
                template: Template.tagresult
            }
        ]
    }

    userTagClass: ->
        if @name in selectedTags.array() then 'primary' else 'basic'

    user_counter: -> Meteor.users.find().count()




Template.nav.events
    'click .toggleSidebar': ->
        $('.ui.sidebar').sidebar 'toggle'


    'autocompleteselect #tagDrilldown': (event, template, doc)->
        selected_tags.push doc.name.toString()
        $('#tagDrilldown').val('')

    'keyup #tagDrilldown': (event, template)->
        event.preventDefault()
        if event.which is 13
            val = $('#tagDrilldown').val()
            switch val
                when 'clear'
                    selected_tags.clear()
                    $('#tagDrilldown').val ''
                    $('#globalsearch').val ''

    'click #homeLink': ->
        selectedTags.clear()

    'keyup #search': (e)->
        e.preventDefault()
        searchTerm = e.target.value.toLowerCase().trim()
        switch e.which
            when 13
                if searchTerm is 'clear'
                    selectedTags.clear()
                    $('#search').val('')
                else
                    selectedTags.push searchTerm
                    $('#search').val('')
            when 8
                if searchTerm is ''
                    selectedTags.pop()

