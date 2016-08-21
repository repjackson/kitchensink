@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.author_id = Meteor.userId()
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tag_count = doc.tags.length
    Meteor.call 'generate_person_cloud', Meteor.userId()
), fetchPrevious: true

Docs.helpers
    author: -> Meteor.users.findOne @author_id


Meteor.methods
    add: (tags=[])->
        id = Docs.insert
            tags: tags
        Meteor.call 'generate_person_cloud', Meteor.userId()
        return id


    delete: (id)->
        Docs.remove id

    untag: (tag, doc_id)->
        Docs.update doc_id,
            $pull: tag

    tag: (tag, doc_id)->
        Docs.update doc_id,
            $addToSet: tags: tag

FlowRouter.route '/edit/:doc_id',
    name: 'edit'
    action: ->
        BlazeLayout.render 'layout', main: 'edit'

FlowRouter.route '/',
    name: 'home'
    action: ->
        BlazeLayout.render 'layout', main: 'docs'
