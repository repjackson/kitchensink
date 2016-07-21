@selected_doc_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []



Template.docs.onCreated ->
    # @autorun -> Meteor.subscribe('docs', selected_doc_tags.array())
    # @autorun -> Meteor.subscribe 'docs', selected_doc_tags.array(), Session.get('selected_user'), Session.get('upvoted_cloud'), Session.get('downvoted_cloud'), Session.get('unvoted')
    @autorun -> Meteor.subscribe 'docs', selected_doc_tags.array(), selected_authors.array(), Session.get('upvoted_cloud'), Session.get('downvoted_cloud'), Session.get('unvoted')

    # @autorun -> Meteor.subscribe('doc_tags', selected_doc_tags.array())


Template.docs.helpers
    docs: -> 
        # Docs.find({ _id: $ne: Meteor.userId() })
        Docs.find({ }, 
            sort:
                tag_count: 1
                points: -1
            limit: 3)

    tag_class: -> if @valueOf() in selected_doc_tags.array() then 'primary' else ''



Template.doc.onCreated ->
    # console.log Template.currentData()
    @autorun -> Meteor.subscribe('review_doc', Template.currentData()._id)
    @autorun -> Meteor.subscribe 'person', @author_id


Template.doc.helpers
    # doc_tag_class: -> if @valueOf() in selected_doc_tags.array() then 'blue' else ''
    
    can_retrieve_points: -> if @donators and Meteor.userId() in @donators then true else false

    
    current_user_donations: ->
        if @donators and Meteor.userId() in @donators
            result = _.find @donations, (donation)->
                donation.user is Meteor.userId()
            result.amount
        else return 0

    
    doc_tag_class: ->
        result = ''
        if @valueOf() in selected_doc_tags.array() then result += ' primary' else result += ' '
        # if Meteor.userId() in @up_voters then result += ' green'
        # else if Meteor.userId() in @down_voters then result += ' red'
        # if Meteor.userId() in Template.parentData(1).up_voters then result += ' green'
        # else if Meteor.userId() in Template.parentData(1).down_voters then result += ' red'
        return result

    
    # doc_tag_class: -> if @name in selected_doc_tags.array() then 'blue' else ''
    
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled '
        # else if Meteor.user().points < 1 then 'disabled '
        else if Meteor.userId() in @up_voters then 'green'
        else ''

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled '
        # else if Meteor.user().points < 1 then 'disabled '
        else if Meteor.userId() in @down_voters then 'red'
        else ''

    select_user_button_class: -> if Session.equals 'selected_user', @author_id then 'primary' else 'basic'
    author_downvotes_button_class: -> if Session.equals 'downvoted_cloud', @author_id then 'primary' else 'basic'
    author_upvotes_button_class: -> if Session.equals 'upvoted_cloud', @author_id then 'primary' else 'basic'

    
    review_tags: -> 
        # console.log @
        review_doc = Docs.findOne(author_id: Meteor.userId(), recipient_id: @_id)
        # console.log review_doc
        review_doc?.tags
    
    is_author: -> Meteor.userId() is @author_id
    
    settings: ->
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    # token: ''
                    collection: Tags
                    field: 'name'
                    matchAll: true
                    template: Template.tag_result
                }
            ]
        }

    like_button_class: -> if @_id in Meteor.user().docs_you_like then 'primary' else 'basic' 

    up_voted_match_cloud: ->
        my_upvoted_cloud = Meteor.user().upvoted_cloud
        my_upvoted_list = Meteor.user().upvoted_list
        # console.log 'my_upvoted_cloud', my_upvoted_cloud
        # console.log @
        otherUser = Meteor.users.findOne @author_id
        other_upvoted_cloud = otherUser?.upvoted_cloud
        other_upvoted_list = otherUser?.upvoted_list
        # console.log 'otherCloud', other_upvoted_cloud
        intersection = _.intersection(my_upvoted_list, other_upvoted_list)
        intersection_cloud = []
        total_count = 0
        for tag in intersection
            my_tag_object = _.findWhere my_upvoted_cloud, name: tag
            other_tag_object = _.findWhere other_upvoted_cloud, name: tag
            # console.log other_tag_object.count
            min = Math.min(my_tag_object.count, other_tag_object.count)
            total_count += min
            intersection_cloud.push
                tag: tag
                min: min
        sorted_cloud = _.sortBy(intersection_cloud, 'min').reverse()
        result = {}
        result.cloud = sorted_cloud
        result.total_count = total_count
        return result



Template.doc.events
    'click .doc_tag': -> if @valueOf() in selected_doc_tags.array() then selected_doc_tags.remove(@valueOf()) else selected_doc_tags.push(@valueOf())

    'click .add_liked_person': ->
        # console.log @_id
        Meteor.call 'add_liked_person', @_id

    'click .review_tag': (e,t)->
        tag = @valueOf()
        # console.log Template.currentData()._id
        Meteor.call 'remove_tag', Template.currentData()._id, tag, ->
            t.$('.review_user').val(tag)

    'autocompleteselect .review_user': (event, template, doc) ->
        # console.log 'selected ', doc
        Meteor.call 'tag_user', Template.parentData(0)._id, doc.name, ->
            $('.review_user').val ''

    'click .edit_doc': ->
        FlowRouter.go "/docs/edit/#{@_id}"
        
    # 'click .vote_down': ->
    #     if Meteor.userId() in @down_voters
    #         if confirm "Undo Downvote? This will give you and #{@author.username} back a point."
    #             Meteor.call 'vote_down', @_id
    #     else
    #         if confirm "Confirm Downvote? This will cost you a point and take one from #{@author.username}"
    #             if Meteor.userId() then Meteor.call 'vote_down', @_id

    # 'click .vote_up': ->
    #     if Meteor.userId() in @up_voters
    #         if confirm "Undo Upvote? This will give you back a point and take one from #{@author.username}."
    #             Meteor.call 'vote_up', @_id
    #     else
    #         if confirm "Confirm Upvote? This will give a point from you to #{@author.username}."
    #             if Meteor.userId() then Meteor.call 'vote_up', @_id

    
    'click .vote_up': -> Meteor.call 'vote_up', @_id

    'click .vote_down': -> Meteor.call 'vote_down', @_id
    

    'click .author_filter_button': ->
        if @username in selected_authors.array() then selected_authors.remove @username else selected_authors.push @username

    'click .clone_doc': ->
        # if confirm 'Clone?'
        id = Docs.insert
            tags: @tags
            body: @body
        FlowRouter.go "/docs/edit/#{id}"

    'click .buy_item': (e,t)->
        if confirm "Buy for #{this.cost} points?"
            Meteor.call 'buy_item', @_id

    'click .send_point': -> Meteor.call 'send_point', @_id
    'click .retrieve_point': -> Meteor.call 'retrieve_point', @_id
