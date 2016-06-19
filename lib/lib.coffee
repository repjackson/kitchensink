@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'


Docs.before.insert (userId, doc)->
    doc.up_voters = []
    doc.down_voters = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.username = Meteor.user().username
    doc.points = 0
    return


Meteor.methods
    create_doc: ()->
        Docs.insert({})
            # tags: [Meteor.user().username]

    deleteDoc: (id)->
        Docs.remove id

    removetag: (tag, docId)->
        Docs.update docId,
            $pull: tag

    addtag: (tag, docId)->
        Docs.update docId,
            $addToSet: tags: tag

