Template.people.onCreated ->
    @autorun -> Meteor.subscribe('people', selectedtags.array())
    @autorun -> Meteor.subscribe('me')

Template.people.helpers
    # people: -> Meteor.users.find({ _id: $ne: Meteor.userId() })
    people: -> Meteor.users.find()


Template.person.onCreated ->
    # Meteor.subscribe 'person', @data._id


Template.person.helpers
    isUser: -> @_id is Meteor.userId()

    tagClass: ->
        if @valueOf() in selectedtags.array() then 'primary' else 'basic'

    matchedtags: ->
        _.intersection @tags, Meteor.user().tags


Template.person.events
    'click .tag': ->
        if @valueOf() in selectedtags.array() then selectedtags.remove @valueOf() else selectedtags.push @valueOf()
