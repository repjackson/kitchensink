@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'
@User_matches = new Meteor.Collection 'user_matches'


Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.username = Meteor.user().username
    doc.points = 0
    return


Meteor.methods
    create_doc: (tags)->
        Docs.insert
            tags: tags
            tag_count: tags.length
        Meteor.call 'generate_user_cloud'

    delete_doc: (id)->
        Docs.remove id

    remove_tag: (tag, docId)->
        Docs.update docId,
            $pull: tag


    add_tag: (tag, docId)->
        Docs.update docId,
            $addToSet: tags: tag