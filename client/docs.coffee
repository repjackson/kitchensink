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

    voteUpButtonClass: ->
        if not Meteor.userId() then 'disabled basic'
        else if Meteor.userId() in @upVoters then 'green'
        else 'basic'

    voteDownButtonClass: ->
        if not Meteor.userId() then 'disabled basic'
        else if Meteor.userId() in @downVoters then 'red'
        else 'basic'

    docTagClass: ->
        result = ''
        if @valueOf() in selectedTags.array() then result += ' primary' else result += ' basic'
        if Meteor.userId() in Template.parentData(1).upVoters then result += ' green'
        else if Meteor.userId() in Template.parentData(1).downVoters then result += ' red'
        return result


Template.view.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .docTag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()

    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .authorFilterButton': ->
        if @username in selectedUsernames.array() then selectedUsernames.remove @username else selectedUsernames.push @username

    'click .cloneDoc': ->
        if confirm 'Clone?'
            id = Docs.insert
                tags: @tags
            FlowRouter.go "/edit/#{id}"

    'click .voteDown': ->
        if Meteor.userId()
            # if @points is 0 or (@points is 1 and Meteor.userId() in @upVoters)
            #     if confirm 'Confirm downvote? This will delete the doc.'
            #         Meteor.call 'voteDown', @_id
            # else
            Meteor.call 'voteDown', @_id

    'click .voteUp': -> if Meteor.userId() then Meteor.call 'voteUp', @_id

