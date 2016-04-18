
Docs.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


Accounts.onCreateUser (options, user) ->
    user.taggers = []
    user.userTags = []
    user.tagCloud = []
    user.tagList = []
    user

# Accounts.onCreateUser (options, user)->
#     user.points = 100
#     user


Messages.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


