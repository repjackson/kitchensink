
Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()



# Accounts.onCreateUser (options, user) ->
#     user.tagCloud = []
#     user.tagList = []
#     user


