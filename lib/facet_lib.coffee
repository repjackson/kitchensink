@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'
@Usernames = new Meteor.Collection 'usernames'
@Messages = new Meteor.Collection 'messages'
@Importers = new Meteor.Collection 'importers'


Docs.before.insert (userId, doc)->
    doc.up_voters = []
    doc.down_voters = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.points = 0
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tagCount = doc.tags.length
    Meteor.call 'generatePersonalCloud', Meteor.userId()
), fetchPrevious: true


Slingshot.fileRestrictions 'myFileUploads',
    allowedFileTypes: null
    maxSize: 10 * 1024 * 1024


Docs.helpers
    author: -> Meteor.users.findOne @authorId
Messages.helpers
    from: (doc)-> Meteor.users.findOne @fromId
    to: (doc)-> Meteor.users.findOne @toId





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

FlowRouter.route '/',
  triggersEnter: [ (context, redirect) ->
    redirect '/docs'
 ]
  action: (_params) ->
    throw new Error('this should not get called')



FlowRouter.route '/docs', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'cloud'
        main: 'docs'

FlowRouter.route '/edit/:docId', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit'

FlowRouter.route '/profile', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'

FlowRouter.route '/unvoted', action: (params) ->
    Session.set('view', 'unvoted')
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'docCloud'
        main: 'docs'

FlowRouter.route '/people', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'userCloud'
        main: 'people'

FlowRouter.route '/exchange', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'exchange'

FlowRouter.route '/leaderboard', action: (params) ->
    BlazeLayout.render 'layout', main: 'leaderboard'

FlowRouter.route '/importers', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'importerList'

FlowRouter.route '/importers/:iId', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'importerView'

FlowRouter.route '/bulk', action: (params) ->
    analytics.page()
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'bulk'
FlowRouter.route '/marketplace', action: (params) ->
    Session.set('view', 'marketplace')
    BlazeLayout.render 'layout', main: 'home'

