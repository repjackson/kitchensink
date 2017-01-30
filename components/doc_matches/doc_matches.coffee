if Meteor.isClient
    Template.doc_matches.events
        'click #find_top_doc_matches': ->
            Meteor.call 'find_top_doc_matches', @_id
