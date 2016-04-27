@Peopletags = new Meteor.Collection 'people_tags'
@Conversationtags = new Meteor.Collection 'conversation_tags'
@Messages = new Meteor.Collection 'messages'
@Conversations = new Meteor.Collection 'conversations'
@Events = new Meteor.Collection 'events'
@Eventtags = new Meteor.Collection 'event_tags'


Messages.helpers
    author: -> Meteor.users.findOne @authorId
    recipient: -> Meteor.users.findOne @recipientId
    when: -> moment(@timestamp).fromNow()


Conversations.helpers
    participants: ->
        participantArray = []
        for id in @participantIds
            participantArray.push(Meteor.users.findOne(id)?.username)
        participantArray

Events.helpers
    attendees: ->
        attendeeArray = []
        for id in @attendeeIds
            attendeeArray.push(Meteor.users.findOne(id)?.username)
        attendeeArray


Meteor.methods
    create_conversation: (tags, otherUserId)->
        existingConversation = Conversations.findOne tags: tags
        if existingConversation then return
        else
            Conversations.insert
                tags: tags
                authorId: Meteor.userId()
                participantIds: [Meteor.userId(), otherUserId]

    create_event: (tags)->
        Events.insert
            tags: tags
            hostId: Meteor.userId()
            attendeeIds: [Meteor.userId()]

    add_event_message: (text, eventId)->
        Messages.insert
            timestamp: Date.now()
            authorId: Meteor.userId()
            text: text
            eventId: eventId

    closeConversation: (id)->
        Conversations.remove id
        Messages.remove conversationId: id

    joinConversation: (id)->
        Conversations.update id,
            $addToSet:
                participantIds: Meteor.userId()

    leaveConversation: (id)->
        Conversations.update id,
            $pull:
                participantIds: Meteor.userId()

    join_event: (id)->
        Events.update id,
            $addToSet:
                attendeeIds: Meteor.userId()

    leave_event: (id)->
        Events.update id,
            $pull:
                attendeeIds: Meteor.userId()

    removetag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag

    addtag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag

    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username

    send_message: (body, recipientId) ->
        Messages.insert
            timestamp: Date.now()
            authorId: Meteor.userId()
            body: body
            recipientId: recipientId

    add_message: (text, conversationId) ->
        Messages.insert
            timestamp: Date.now()
            authorId: Meteor.userId()
            text: text
            conversationId: conversationId


AccountsTemplates.configure
    defaultLayout: 'layout'
    defaultLayoutRegions:
        nav: 'nav'
    defaultContentRegion: 'main'
    showForgotPasswordLink: true
    overrideLoginErrors: true
    enablePasswordChange: true

    # sendVerificationEmail: true
    # enforceEmailVerification: true
    #confirmPassword: true
    #continuousValidation: false
    #displayFormLabels: true
    #forbidClientAccountCreation: true
    #formValidationFeedback: true
    #homeRoutePath: '/'
    #showAddRemoveServices: false
    #showPlaceholders: true

    negativeValidation: true
    positiveValidation: true
    negativeFeedback: false
    positiveFeedback: true

    # Privacy Policy and Terms of Use
    #privacyUrl: 'privacy'
    #termsUrl: 'terms-of-use'

pwd = AccountsTemplates.removeField('password')
AccountsTemplates.removeField 'email'
AccountsTemplates.addFields [
    {
        _id: 'username'
        type: 'text'
        displayName: 'username'
        required: true
        minLength: 3
    }
    # {
    #     _id: 'email'
    #     type: 'email'
    #     required: false
    #     displayName: 'email'
    #     re: /.+@(.+){2,}\.(.+){2,}/
    #     errStr: 'Invalid email'
    # }
    # {
    #     _id: 'username_and_email'
    #     type: 'text'
    #     required: false
    #     displayName: 'Login'
    # }
    pwd
]

AccountsTemplates.configureRoute 'changePwd'
AccountsTemplates.configureRoute 'forgotPwd'
AccountsTemplates.configureRoute 'resetPwd'
AccountsTemplates.configureRoute 'signIn'
AccountsTemplates.configureRoute 'signUp'
AccountsTemplates.configureRoute 'verifyEmail'


FlowRouter.route '/', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'cloud'
        main: 'people'

FlowRouter.route '/profile', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'

FlowRouter.route '/messages', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'messagePage'

FlowRouter.route '/conversations', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'conversation_cloud'
        main: 'conversations'

FlowRouter.route '/events', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'event_cloud'
        main: 'events'

# FlowRouter.route '/editConversation/:docId', action: (params) ->
#     BlazeLayout.render 'layout',
#         main: 'conversation'
