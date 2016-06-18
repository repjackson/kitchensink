@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'


Docs.before.insert (userId, doc)->
    doc.up_voters = []
    doc.down_voters = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.points = 0
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tagCount = doc.tags.length
    Meteor.call 'generatePersonalCloud', Meteor.userId()
), fetchPrevious: true


Docs.helpers
    author: -> Meteor.users.findOne @authorId





Meteor.methods
    create_doc: ()->
        Docs.insert
            tags: [Meteor.user().username]

    deleteDoc: (id)->
        Docs.remove id

    removetag: (tag, docId)->
        Docs.update docId,
            $pull: tag

    addtag: (tag, docId)->
        Docs.update docId,
            $addToSet: tags: tag

    vote_up: (id)->
        doc = Docs.findOne id
        if Meteor.userId() in doc.up_voters #undo upvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1
            Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.down_voters #switch downvote to upvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 2
            Meteor.users.update doc.authorId, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1
            Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.call 'generatePersonalCloud', Meteor.userId()

    vote_down: (id)->
        doc = Docs.findOne id
        if Meteor.userId() in doc.down_voters #undo downvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1
            Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.up_voters #switch upvote to downvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -2
            Meteor.users.update doc.authorId, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1
            Meteor.users.update Meteor.userId(), $inc: points: -1
        Meteor.call 'generatePersonalCloud', Meteor.userId()
