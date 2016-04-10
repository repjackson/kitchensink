@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Messages = new Meteor.Collection 'messages'
@Usernames = new Meteor.Collection 'usernames'


Docs.before.insert (userId, doc)->
    doc.upVoters = [userId]
    doc.downVoters = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.username = Meteor.user().username
    doc.points = 1
    doc.cost = 0
    doc.tagCount = doc.tags.length
    return


Docs.helpers
    author: (doc)-> Meteor.users.findOne @authorId


Messages.helpers
    from: (doc)-> Meteor.users.findOne @fromId
    to: (doc)-> Meteor.users.findOne @toId


Meteor.methods
    voteUp: (id)->
        doc = Docs.findOne id
        if Meteor.userId() in doc.upVoters #undo upvote
            Docs.update id,
                $pull: upVoters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1

        else if Meteor.userId() in doc.downVoters #switch downvote to upvote
            Docs.update id,
                $pull: downVoters: Meteor.userId()
                $addToSet: upVoters: Meteor.userId()
                $inc: points: 2
            Meteor.users.update doc.authorId, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: upVoters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1
        Meteor.call 'generatePersonalCloud', Meteor.userId()


    voteDown: (id)->
        doc = Docs.findOne id
        # if doc.points is 0 or doc.points is 1 and Meteor.userId() in doc.upVoters
        #     Docs.remove id
        if Meteor.userId() in doc.downVoters #undo downvote
            Docs.update id,
                $pull: downVoters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1

        else if Meteor.userId() in doc.upVoters #switch upvote to downvote
            Docs.update id,
                $pull: upVoters: Meteor.userId()
                $addToSet: downVoters: Meteor.userId()
                $inc: points: -2
            Meteor.users.update doc.authorId, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: downVoters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1
        Meteor.call 'generatePersonalCloud', Meteor.userId()


    updatelocation: (docid, result)->
        addresstags = (component.long_name for component in result.address_components)
        loweredAddressTags = _.map(addresstags, (tag)->
            tag.toLowerCase()
            )

        #console.log addresstags

        doc = Docs.findOne docid
        tagsWithoutAddress = _.difference(doc.tags, doc.addresstags)
        tagsWithNew = _.union(tagsWithoutAddress, loweredAddressTags)

        Docs.update docid,
            $set:
                tags: tagsWithNew
                locationob: result
                addresstags: loweredAddressTags


FlowRouter.route '/', action: (params) ->
    Session.set('view', 'all')
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'cloud'
        main: 'docs'

FlowRouter.route '/edit/:docId', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'edit'

FlowRouter.route '/mine', action: (params) ->
    Session.set('view', 'mine')
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'cloud'
        main: 'docs'

FlowRouter.route '/unvoted', action: (params) ->
    Session.set('view', 'unvoted')
    BlazeLayout.render 'layout',
        nav: 'nav'
        cloud: 'cloud'
        main: 'docs'

FlowRouter.route '/profile', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'profile'

FlowRouter.route '/marketplace', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'marketplace'


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