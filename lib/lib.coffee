@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'


Meteor.methods
    remove_tag: (recipient_id, tag)->
        review_doc = Docs.findOne author_id: Meteor.userId(), recipient_id: recipient_id
        
        Docs.update review_doc._id,
            $pull: tags: tag

    add_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag

    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username


    tag_user: (recipient_id, tag)->
        user_tag_doc = Docs.findOne author_id: Meteor.userId(), recipient_id: recipient_id
        
        if user_tag_doc
            Docs.update user_tag_doc._id,
                $addToSet: tags: tag
        else
            Docs.insert
                recipient_id: recipient_id
                author_id: Meteor.userId()
                tags: [tag]
        Meteor.call 'generate_person_cloud', recipient_id