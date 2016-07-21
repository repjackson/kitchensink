@selected_event_tags = new ReactiveArray []

Template.comments.onCreated ->
    doc_id = Template.parentData(0)._id
    self = @
    self.autorun ->
        self.subscribe 'doc_comments', doc_id
    

Template.comments.helpers
    comments: -> 
        doc_id = Template.parentData(0)._id
        Comments.find( doc_id: doc_id )



Template.comments.events
    'keydown .new_comment': (e,t)->
        if e.which is 13
            text = t.$('.new_comment').val()
            if text.length > 0
                doc_id = Template.parentData(0)._id
                Meteor.call 'insert_comment', doc_id, text,->
                    t.$('.new_comment').val('')

Template.comment.helpers
    is_author: -> Meteor.userId() and Meteor.userId() is @author_id 

Template.comment.events
    'click .delete_comment': -> Meteor.call 'delete_comment', @_id