Meteor.methods
    voteUp: (id)->
        doc = Docs.findOne id
        if Meteor.userId() in doc.upVoters #undo upvote
            Docs.update id,
                $pull: upVoters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1

        else if Meteor.userId() in doc.downVoters #switch downvote to upvote
            Docs.update id,
                $pull: downVoters: Meteor.userId()
                $addToSet: upVoters: Meteor.userId()
                $inc: points: 2
            Meteor.users.update doc.authorId, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: upVoters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1
        Meteor.call 'generatePersonalCloud', Meteor.userId()


    voteDown: (id)->
        doc = Docs.findOne id
        # if doc.points is 0 or doc.points is 1 and Meteor.userId() in doc.upVoters
        #     Docs.remove id
        if Meteor.userId() in doc.downVoters #undo downvote
            Docs.update id,
                $pull: downVoters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1

        else if Meteor.userId() in doc.upVoters #switch upvote to downvote
            Docs.update id,
                $pull: upVoters: Meteor.userId()
                $addToSet: downVoters: Meteor.userId()
                $inc: points: -2
            Meteor.users.update doc.authorId, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: downVoters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1
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

    toggleFieldTag: (id, fieldName, value)->
        Importers.update {
            _id: id
            fieldsObject: $elemMatch:
                name: fieldName
            }, $set: 'fieldsObject.$.tag': value
