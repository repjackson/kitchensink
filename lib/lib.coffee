@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'


Docs.before.insert (userId, doc)->
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.username = Meteor.user().username
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tagCount = doc.tags.length
), fetchPrevious: true




Docs.helpers
    author: (doc)-> Meteor.users.findOne @authorId


Meteor.methods
    createDoc: (tags=[])->
        Docs.insert
            tags: tags


    deleteDoc: (id)->
        Docs.remove id

    addBookmark: (tags)->
        Meteor.users.update Meteor.userId(),
            $addToSet:
                bookmarks: tags

    removetag: (tag, docId)->
        Docs.update docId,
            $pull: tag

    addtag: (tag, docId)->
        Docs.update docId,
            $addToSet: tags: tag


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
        main: 'docs'

FlowRouter.route '/edit/:docId', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit'

