@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'


Docs.before.insert (userId, doc)->
    doc.upVoters = [userId]
    doc.downVoters = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.username = Meteor.user().username
    doc.points = 1
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
    sendPoint: (id)->
        doc = Docs.findOne id
        # check if current user has sent points
        if doc.donators and Meteor.userId() in doc.donators
            Docs.update {
                _id: id
                "donations.user": Meteor.userId()
                },
                    $inc:
                        "donations.$.amount": 1
                        points: 1
            Meteor.users.update Meteor.userId(), $inc: points: -1

        else
            Docs.update id,
                $addToSet:
                    donators: Meteor.userId()
                    donations:
                        user: Meteor.userId()
                        amount: 1
            Meteor.users.update Meteor.userId(), $inc: points: -1


    retrievePoint: (id)->
        doc = Docs.findOne id
        currentId = Meteor.userId()
        # check if current user has sent points
        if doc.donators and Meteor.userId() in doc.donators
            donationEntry = _.find doc.donations, (donation)->
                donation.user is currentId
            if donationEntry.amount is 1
                Docs.update {
                    _id: id
                    "donations.user": Meteor.userId()
                    },
                    $pull: { donations: {user: Meteor.userId()}, donators: Meteor.userId()}
                    $inc: points: -1

                Meteor.users.update Meteor.userId(), $inc: points: 1

            else
                Docs.update {
                    _id: id
                    "donations.user": Meteor.userId()
                    }, $inc: "donations.$.amount": -1, points: -1

                Meteor.users.update Meteor.userId(), $inc: points: 1

        else
            Docs.update id,
                $addToSet:
                    donators: Meteor.userId()
                    donations:
                        user: Meteor.userId()
                        amount: 1
                $inc: points: -1

            Meteor.users.update Meteor.userId(), $inc: points: 1





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

