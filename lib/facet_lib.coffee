@Tags = new Meteor.Collection 'tags'
@Docs = new Meteor.Collection 'docs'
@Usernames = new Meteor.Collection 'usernames'


Docs.before.insert (userId, doc)->
    doc.up_voters = [userId]
    doc.down_voters = []
    doc.timestamp = Date.now()
    doc.authorId = Meteor.userId()
    doc.points = 1
    doc.cost = 0
    return

Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
    doc.tagCount = doc.tags.length
    Meteor.call 'generatePersonalCloud', Meteor.userId()
), fetchPrevious: true




Docs.helpers
    author: ->
        Meteor.users.findOne @authorId


Meteor.methods
    createDoc: (tags=[])->
        Meteor.users.update Meteor.userId(),
            $inc: points: 1
        Docs.insert
            tags: tags

    deleteDoc: (id)->
        Docs.remove id

    update_username: (username)->
        existing_user = Meteor.users.findOne username:username
        if existing_user then throw new Meteor.Error 500, 'username exists'
        else
            Meteor.users.update Meteor.userId(),
                $set: username: username

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

    vote_up: (id)->
        doc = Docs.findOne id
        if Meteor.userId() in doc.up_voters #undo upvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1

        else if Meteor.userId() in doc.down_voters #switch downvote to upvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 2
            Meteor.users.update doc.authorId, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: up_voters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1
        Meteor.call 'generatePersonalCloud', Meteor.userId()

    vote_down: (id)->
        doc = Docs.findOne id
        # if doc.points is 0 or doc.points is 1 and Meteor.userId() in doc.up_voters
        #     Docs.remove id
        if Meteor.userId() in doc.down_voters #undo downvote
            Docs.update id,
                $pull: down_voters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.authorId, $inc: points: 1

        else if Meteor.userId() in doc.up_voters #switch upvote to downvote
            Docs.update id,
                $pull: up_voters: Meteor.userId()
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -2
            Meteor.users.update doc.authorId, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: down_voters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.authorId, $inc: points: -1
        Meteor.call 'generatePersonalCloud', Meteor.userId()

    buy_item: (id)->
        doc = Docs.findOne id
        Meteor.users.update Meteor.userId(),
            $inc: points: -doc.cost
        Meteor.users.update doc.authorId,
            $inc: points: doc.cost
        Docs.update id,
            $set:
                bought: true
                buyerId: Meteor.userId()

    # send_point: (id)->
    #     doc = Docs.findOne id
    #     # check if current user has sent points
    #     if doc.donators and Meteor.userId() in doc.donators
    #         Docs.update {
    #             _id: id
    #             "donations.user": Meteor.userId()
    #             },
    #                 $inc:
    #                     "donations.$.amount": 1
    #                     points: 1
    #         Meteor.users.update Meteor.userId(), $inc: points: -1

    #     else
    #         Docs.update id,
    #             $addToSet:
    #                 donators: Meteor.userId()
    #                 donations:
    #                     user: Meteor.userId()
    #                     amount: 1
    #         Meteor.users.update Meteor.userId(), $inc: points: -1
    #     Meteor.users.update doc.authorId, $inc: points: 1

    # retrieve_point: (id)->
    #     doc = Docs.findOne id
    #     currentId = Meteor.userId()
    #     # check if current user has sent points
    #     if doc.donators and Meteor.userId() in doc.donators
    #         donationEntry = _.find doc.donations, (donation)->
    #             donation.user is currentId
    #         if donationEntry.amount is 1
    #             Docs.update {
    #                 _id: id
    #                 "donations.user": Meteor.userId()
    #                 },
    #                 $pull: { donations: {user: Meteor.userId()}, donators: Meteor.userId()}
    #                 $inc: points: -1

    #             Meteor.users.update Meteor.userId(), $inc: points: 1
    #         else
    #             Docs.update {
    #                 _id: id
    #                 "donations.user": Meteor.userId()
    #                 }, $inc: "donations.$.amount": -1, points: -1

    #             Meteor.users.update Meteor.userId(), $inc: points: 1
    #     else
    #         Docs.update id,
    #             $addToSet:
    #                 donators: Meteor.userId()
    #                 donations:
    #                     user: Meteor.userId()
    #                     amount: 1
    #             $inc: points: -1
    #         Meteor.users.update Meteor.userId(), $inc: points: 1
    #     Meteor.users.update doc.authorId, $inc: points: -1

# users
    add_user_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $addToSet: tags: tag

    remove_user_tag: (tag)->
        Meteor.users.update Meteor.userId(),
            $pull: tags: tag



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

FlowRouter.route '/leaderboard', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'leaderboard'

# FlowRouter.route '/store', action: (params) ->
#     selectedTags.clear()
#     selectedTags.push('store')
#     # BlazeLayout.render 'layout',
#     #     nav: 'nav'
#     #     main: 'store'
