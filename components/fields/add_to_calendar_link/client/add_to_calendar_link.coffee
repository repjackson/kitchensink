Template.add_to_calendar_link.events
    'blur #add_to_calendar_link': ->
        add_to_calendar_link = $('#add_to_calendar_link').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: add_to_calendar_link: add_to_calendar_link