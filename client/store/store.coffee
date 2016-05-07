Template.store.onCreated ->
    @autorun -> Meteor.subscribe 'store'

Template.store.helpers
    store_items: -> Docs.find {},
        limit: 5
        sort:
            tagCount: 1
            timestamp: -1
    # docs: -> Docs.find()


Template.store_item.onCreated ->
    Meteor.subscribe 'person', @data.authorId

Template.store_item.helpers
    isAuthor: -> @authorId is Meteor.userId()

    can_buy: -> Meteor.user().points > @cost

    when: -> moment(@timestamp).fromNow()


Template.store_item.events
    'click .editDoc': -> FlowRouter.go "/edit/#{@_id}"

    'click .doc_tag': -> if @valueOf() in selectedTags.array() then selectedTags.remove @valueOf() else selectedTags.push @valueOf()

    'click .deleteDoc': ->
        if confirm 'Delete?'
            Meteor.call 'deleteDoc', @_id

    'click .buy_item': ->
        if confirm "Buy for #{cost} points?"
            Meteor.call 'buy_i', @_id

