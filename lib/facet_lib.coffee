@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'


Docs.before.insert (userId, doc)->
    doc.up_voters = []
    doc.down_voters = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.points = 0
    return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags.length
# ), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @authorId





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

