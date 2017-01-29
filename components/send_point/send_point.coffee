if Meteor.isClient
    Template.send_point.helpers
        send_point_class: -> 
            if Meteor.userId() then ''
            else 'grey disabled'

    
    
    
        sent_points: ->
            if @donators and Meteor.userId() in @donators
                result = _.find @donations, (donation)->
                    donation.user is Meteor.userId()
                result.amount
            else return 0
        
        
        can_retrieve: -> if @donators and Meteor.userId() in @donators then true else false




    Template.send_point.events
        'click .send_point': -> 
            if Meteor.userId() then Meteor.call 'send_point', @_id
            else FlowRouter.go '/sign-in'

            
        'click .retrieve_point': -> Meteor.call 'retrieve_point', @_id


if Meteor.isServer
    Meteor.methods
        send_point: (id)->
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
                Meteor.users.update doc.author_id, $inc: points: 1
    
            else
                Docs.update id,
                    $addToSet: 
                        donators: Meteor.userId()
                        donations:
                            user: Meteor.userId()
                            amount: 1
                Meteor.users.update Meteor.userId(), $inc: points: -1
                Meteor.users.update doc.author_id, $inc: points: 1
    
    
        retrieve_point: (id)->
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
