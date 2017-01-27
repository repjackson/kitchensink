if Meteor.isClient
    
    Template.footer.helpers
        footer: Docs.find()
    
    
    
    # Template.footer.onCreated ->
    #     self = @
    #     self.autorun ->
    #         self.subscribe 'featured_events'
    
    
    Template.footer.events
        'click #submit_contact_form': ->
            if $("#cancel").prop('checked')
                reason='cancel'
            else if $("#question").prop('checked')
                reason='question'
            console.log reason
            
            name = $('#name').val()
            email = $('#email').val()
            message = $('#message').val()
            form_data = 
                name: name
                email: email
                message: message
                reason: reason
            # console.dir form_data
            #get the captcha data
            # captchaData = grecaptcha.getResponse()
            
            Docs.insert
                type: 'submission'
                data: form_data
            , ->
                $('#name').val('')
                $('#email').val('')
                $('#message').val('')
                swal {
                    title: "Thank you, #{form_data.name}."
                    text: "We'll be in touch."
                    type: 'success'
                    animation: false
                    timer: 2000
                    # confirmButtonColor: '#DD6B55'
                }
    
    
            
            # Meteor.call 'formSubmissionMethod', form_data, captchaData, (error, result) ->
            #     # reset the captcha
            #     grecaptcha.reset()
            #     if error
            #         console.log 'There was an error: ' + error.reason
            #     else
            #         console.log 'Success!'
            #         Docs.insert
            #             type: 'submission'
            #             data: form_data
            #         , ->
            #             $('#name').val('')
            #             $('#email').val('')
            #             $('#message').val('')
            #     return
            # return
