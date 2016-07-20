@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'
@Usernames = new Meteor.Collection 'usernames'
@Messages = new Meteor.Collection 'messages'



Docs.before.insert (userId, doc)->
    doc.up_voters = []
    doc.down_voters = []
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    doc.points = 0
    return

Docs.helpers 
    author: ->
        Meteor.users.findOne @author_id



Meteor.methods
    remove_tag: (recipient_id, tag)->
        review_doc = Docs.findOne(author_id: Meteor.userId(), recipient_id: recipient_id)
        
        Docs.update review_doc._id,
            $pull: tags: tag
        Meteor.call 'generate_person_cloud', recipient_id
        
    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username

    update_contact: (contact)->
        Meteor.users.update Meteor.userId(),
            $set: contact: contact


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
        
        
    add_liked_person: (user_id)->
        if not Meteor.user().people_you_like
            Meteor.users.update Meteor.userId(),
                $set: people_you_like: []
        if user_id in Meteor.user().people_you_like
            Meteor.users.update Meteor.userId(),
                $pull: people_you_like: user_id 
        else
            Meteor.users.update Meteor.userId(),
                $addToSet: people_you_like: user_id 