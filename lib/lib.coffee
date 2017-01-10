@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    doc.points = 0
    doc.up_voters = []
    doc.down_voters = []
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tag_count = doc.tags.length
    # Meteor.call 'generate_person_cloud', Meteor.userId()
), fetchPrevious: true

Docs.helpers
    author: -> Meteor.users.findOne @author_id


Meteor.methods
    add: (tags=[])->
        id = Docs.insert
            tags: tags
        # Meteor.call 'generate_person_cloud', Meteor.userId()
        return id


    delete: (id)->
        Docs.remove id

    untag: (tag, doc_id)->
        Docs.update doc_id,
            $pull: tag

    tag: (tag, doc_id)->
        Docs.update doc_id,
            $addToSet: tags: tag

    vote_up: (id)->
        doc = Docs.findOne id
        if not doc.up_voters
            Docs.update id,
                $set: 
                    up_voters: []
                    down_voters: []
        else if Meteor.userId() in doc.up_voters #undo upvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.author_id, $inc: points: -1
            Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.down_voters #switch downvote to upvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 2
            Meteor.users.update doc.author_id, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.author_id, $inc: points: 1
            Meteor.users.update Meteor.userId(), $inc: points: -1

    vote_down: (id)->
        doc = Docs.findOne id
        if not doc.down_voters
            Docs.update id,
                $set: 
                    up_voters: []
                    down_voters: []
        else if Meteor.userId() in doc.down_voters #undo downvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.author_id, $inc: points: 1
            Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.up_voters #switch upvote to downvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -2
            Meteor.users.update doc.author_id, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.author_id, $inc: points: -1
            Meteor.users.update Meteor.userId(), $inc: points: -1






FlowRouter.route '/edit/:doc_id',
    name: 'edit'
    action: ->
        BlazeLayout.render 'layout', 
            main: 'edit'

FlowRouter.route '/',
    name: 'home'
    action: ->
        BlazeLayout.render 'layout', 
            cloud: 'cloud'
            main: 'docs'
