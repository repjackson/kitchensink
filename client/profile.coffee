@selectedtags = new ReactiveArray []


Template.profile.onCreated ->
    @autorun -> Meteor.subscribe 'people'
    @autorun -> Meteor.subscribe 'myTags', selectedtags.array()
    self = @
    self.autorun ->
        # self.subscribe 'user_matches', selected_tags.array()
        self.subscribe 'everyone'



Template.profile.helpers
    people: -> Meteor.users.find()

    user_matches:->
        users = Meteor.users.find({_id: $ne: Meteor.userId()}).fetch()
        user_matches = []
        for user in users
            tag_intersection = _.intersection(user.tags, Meteor.user().tags)
            user_matches.push
                matched_user: user.username
                tag_intersection: tag_intersection
                length: tag_intersection.length
        sortedList = _.sortBy(user_matches, 'length').reverse()
        return sortedList


Template.profile.events
    'keydown #add_tag': (e,t)->
        e.preventDefault
        tag = $('#add_tag').val().toLowerCase().trim()
        switch e.which
            when 13
                if tag.length > 0
                    Meteor.call 'add_tag', tag, ->
                        $('#add_tag').val('')

    # 'keydown #username': (e,t)->
    #     e.preventDefault
    #     username = $('#username').val().trim()
    #     switch e.which
    #         when 13
    #             if username.length > 0
    #                 Meteor.call 'update_username', username, (err,res)->
    #                     if err
    #                         alert 'Username exists.'
    #                         $('#username').val(Meteor.user().username)
    #                     else
    #                         alert "Updated username to #{username}."

    'click .tag': ->
        tag = @valueOf()
        Meteor.call 'remove_tag', tag, ->
            $('#add_tag').val(tag)
