Template.docs.onCreated ->
    @autorun -> Meteor.subscribe('docs', selectedTags.array())

Template.docs.helpers
    # docs: -> Docs.find({}, limit: 1)
    docs: -> Docs.find()


Template.view.onCreated ->
    Meteor.subscribe 'person', @data.authorId

Template.view.helpers
    isAuthor: -> @authorId is Meteor.userId()

    when: -> moment(@timestamp).fromNow()

    docTagClass: ->
        if @valueOf() in selectedTags.array() then 'primary' else 'basic'


    authorFilterButtonClass: ->
        if @username in selectedUsernames.array() then 'primary' else 'basic'


    author: -> Meteor.users.findOne(@authorId)


Template.view.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .docTag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()


    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .authorFilterButton': ->
        if @username in selectedUsernames.array() then selectedUsernames.remove @username else selectedUsernames.push @username
