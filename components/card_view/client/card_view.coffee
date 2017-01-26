Template.card_view.events
    'click .doc_tag': ->
        if @valueOf() in selected_tags.array() then selected_tags.remove @valueOf() else selected_tags.push @valueOf()
        
Template.card_view.helpers
    tag_class: -> if @valueOf() in selected_tags.array() then 'red' else 'basic'

    tags: ->
        _.without(@tags, 'ecosystem') 
