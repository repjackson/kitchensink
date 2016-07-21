Comments.allow
    insert: (userId, doc)-> doc.author_id is Meteor.userId()
    update: (userId, doc)-> doc.author_id is Meteor.userId()
    remove: (userId, doc)-> doc.author_id is Meteor.userId()
    
    
    
Meteor.publish 'doc_comments', (doc_id)->
    Comments.find doc_id: doc_id
