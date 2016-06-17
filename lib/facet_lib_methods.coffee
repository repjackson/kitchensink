Meteor.methods
    createDoc: (tags=[])->
        Docs.insert
            tags: tags

    deleteDoc: (id)->
        Docs.remove id

    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username

    addBookmark: (tags)->
        Meteor.users.update Meteor.userId(),
            $addToSet:
                bookmarks: tags

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

    updatelocation: (docid, result)->
        addresstags = (component.long_name for component in result.address_components)
        loweredAddressTags = _.map(addresstags, (tag)->
            tag.toLowerCase()
            )

        #console.log addresstags

        doc = Docs.findOne docid
        tagsWithoutAddress = _.difference(doc.tags, doc.addresstags)
        tagsWithNew = _.union(tagsWithoutAddress, loweredAddressTags)

        Docs.update docid,
            $set:
                tags: tagsWithNew
                locationob: result
                addresstags: loweredAddressTags

    sendPoint: (id)->
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


# users
    add_user_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag

    remove_user_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag
