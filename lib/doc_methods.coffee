Meteor.methods
    create_doc: ->
        Docs.insert
            timestamp: Date.now()
            author_id: Meteor.userId()
    
    create_doc_with_tags: (tags)->
        Docs.insert
            tags: tags

    deleteDoc: (id)->
        Docs.remove id

    removetag: (tag, doc_id)->
        Docs.update doc_id,
            $pull: tag

    add_bookmark: (tags)->
        Meteor.users.update Meteor.userId(),
            $addToSet:
                bookmarks: tags


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


    update_location: (docid, result)->
        addresstags = (component.long_name for component in result.address_components)
        lowered_address_tags = _.map(addresstags, (tag)->
            tag.toLowerCase()
            )

        #console.log addresstags

        doc = Docs.findOne docid
        tags_without_address = _.difference(doc.tags, doc.addresstags)
        tags_with_new = _.union(tags_without_address, lowered_address_tags)

        Docs.update docid,
            $set:
                tags: tags_with_new
                locationob: result
                addresstags: lowered_address_tags

    send_point: (id)->
        doc = Docs.findOne id
        # check if current user has sent points
        if doc.donators and Meteor.userId() in doc.donators
            Docs.update {
                _id: id
                "donations.user": Meteor.userId()
                },
                    $inc:
                        "donations.$.amount": 1
                        points: 1
            Meteor.users.update Meteor.userId(), $inc: points: -1

        else
            Docs.update id,
                $addToSet:
                    donators: Meteor.userId()
                    donations:
                        user: Meteor.userId()
                        amount: 1
            Meteor.users.update Meteor.userId(), $inc: points: -1


    retrievePoint: (id)->
        doc = Docs.findOne id
        currentId = Meteor.userId()
        # check if current user has sent points
        if doc.donators and Meteor.userId() in doc.donators
            donationEntry = _.find doc.donations, (donation)->
                donation.user is currentId
            if donationEntry.amount is 1
                Docs.update {
                    _id: id
                    "donations.user": Meteor.userId()
                    },
                    $pull: { donations: {user: Meteor.userId()}, donators: Meteor.userId()}
                    $inc: points: -1

                Meteor.users.update Meteor.userId(), $inc: points: 1

            else
                Docs.update {
                    _id: id
                    "donations.user": Meteor.userId()
                    }, $inc: "donations.$.amount": -1, points: -1

                Meteor.users.update Meteor.userId(), $inc: points: 1

        else
            Docs.update id,
                $addToSet:
                    donators: Meteor.userId()
                    donations:
                        user: Meteor.userId()
                        amount: 1
                $inc: points: -1

            Meteor.users.update Meteor.userId(), $inc: points: 1


