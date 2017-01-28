if Meteor.isServer
    get_tweets: (screen_name)->
        if not screen_name
            console.error 'No screen name provided'
            return false
        existingDoc = Docs.findOne tags: $all: ['tweet', screen_name]
        if existingDoc
              throw new Meteor.Error('already-imported',"Tweets from #{screen_name} already exist")

        Twit = new TwitMaker(
            consumer_key: Meteor.settings.twitterConsumerKey
            consumer_secret: Meteor.settings.twitterSecret
            access_token: Meteor.settings.twitterAccessToken
            access_token_secret: Meteor.settings.twitterAccessTokenSecret
            app_only_auth:true)

        Twit.get 'statuses/user_timeline', {
            screen_name: screen_name
            count: 200
            include_rts: false
        }, Meteor.bindEnvironment(((err, data, response) ->
            for tweet in data
                id = Docs.insert
                    body: tweet.text
                Docs.update id,
                    $addToSet: tags: $each: ['tweet', screen_name]
                Meteor.call 'analyze', id, tweet.text
            ))
