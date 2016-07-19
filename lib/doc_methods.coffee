Meteor.methods
    create_doc: ->
        Docs.insert
            timestamp: Date.now()
            author_id: Meteor.userId()
    
    create_doc_with_tags: (tags)->
        Docs.insert
            tags: tags
            timestamp: Date.now()
            author_id: Meteor.userId()

    deleteDoc: (id)->
        Docs.remove id

    removetag: (tag, doc_id)->
        Docs.update doc_id,
            $pull: tag

    # add_bookmark: (tags)->
    #     Meteor.users.update Meteor.userId(),
    #         $addToSet:
    #             bookmarks: tags


    addtag: (tag, doc_id)->
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
            Meteor.users.update doc.authorId, $inc: points: -1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

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
            # Meteor.users.update Meteor.userId(), $inc: points: -1

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
            Meteor.users.update doc.authorId, $inc: points: 1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

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
            # Meteor.users.update Meteor.userId(), $inc: points: -1
