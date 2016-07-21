@Comments = new (Mongo.Collection)('comments')

Comments.helpers
    author: -> Meteor.users.findOne @author_id



Meteor.methods
    'insert_comment': (doc_id, text) ->
        Comments.insert
            doc_id: doc_id
            text: text
            timestamp: Date.now()
            author_id: Meteor.userId()

        Docs.update doc_id,
            $inc: comment_count: 1
    
    'delete_comment': (comment_id) ->
        doc_id = Comments.findOne(comment_id).doc_id
        Comments.remove comment_id

        Docs.update doc_id,
            $inc: comment_count: -1
