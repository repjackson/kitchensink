Template.importer_list.onCreated ->
    self = @
    self.autorun ->
        self.subscribe 'importers'


Template.importer_list.helpers
    importers: -> Importers.find()

Template.importer_list.events
    'click #add_importer': ->
        new_id = Importers.insert
            authorId: Meteor.userId()
        FlowRouter.go "/importers/#{new_id}"


    'click .edit_importer': ->
        FlowRouter.go "/importers/#{@_id}"


Template.importer_view.onCreated ->
    self = @
    self.autorun ->
        iId = FlowRouter.getParam('iId')
        self.subscribe 'importer', iId

    Template.instance().uploading = new ReactiveVar( false )
    return

Template.importer_view.onRendered ->
    Meteor.setTimeout ( ->
        $('select').material_select()
        ), 500
    return

Template.importer_view.helpers
    importerDoc: ->
        iId = FlowRouter.getParam('iId')
        Importers.findOne iId

    uploading: ->
        Template.instance().uploading.get()

    selectedDataType: (fieldName)->
        console.log fieldname
        # console.log _.findWhere(@fieldsObject, {name: fieldName})

Template.importer_view.events
    'keyup #importer_name': (e)->
        switch e.which
            when 13
                id = FlowRouter.getParam('iId')
                Importers.update id,
                    $set: name: e.target.value
                    , (err, res)->
                        alert 'Importer Name Saved', 'success', 'growl-top-right'

    'keyup #importTag': (e)->
        switch e.which
            when 13
                id = FlowRouter.getParam('iId')
                Importers.update id,
                    $set: importTag: e.target.value
                    , (err, res)->
                        alert 'Importer Tag Saved', 'success', 'growl-top-right'


    'click #save_importer': ->
        Meteor.call 'save_importer', FlowRouter.getParam('iId'), $('#urlField').val(), $('#methodField').val(), ->
            FlowRouter.go '/importers'

    'click #run_importer': ->
        Meteor.call 'run_importer', @_id, (err, response)->
            Session.set 'jsonResponse', true

    'click #delete_importer': ->
        if confirm "Delete this Importer?"
            Importers.remove @_id
            FlowRouter.go '/importers'

    'click #testRun': ->
        if confirm "Test this Importer?"
            Meteor.call 'test_run_importer', FlowRouter.getParam 'iId', (err, res)->
                if err then console.log error.reason
                else
                    console.log res

    'click .toggle_tag': (e,t)->
        id = FlowRouter.getParam('iId')
        fieldName = e.currentTarget.id
        value = e.currentTarget.checked
        console.log fieldName
        Meteor.call 'toggleFieldTag', id, fieldName, value, (err, res)->
            if err then console.log error.reason
            else
                alert 'Setting Saved'


    'change .type_selector': (e,t)->
        id = FlowRouter.getParam('iId')
        fieldName = e.currentTarget.id
        value = e.currentTarget.value
        Meteor.call 'update_field_type', id, fieldName, value, (err, res)->
            if err then console.log error.reason
            else
                alert 'Type Saved'

    'change [name="uploadCSV"]': (event, template) ->
        id = FlowRouter.getParam('iId')
        template.uploading.set true
        Papa.parse event.target.files[0],
            header: true
            complete: (results, file) ->
                # console.log results
                # console.log results.data[0]
                fieldNames = results.meta.fields
                firstValues = _.values(results.data[0])
                fields = _.zip(fieldNames, firstValues)
                fieldsObject = _.map(fields, (field)->
                    name: field[0]
                    firstValue: field[1]
                    )
                Importers.update id,
                    $set:
                        fieldsObject: fieldsObject
                Meteor.call 'parseUpload', results.data, (err, res) ->
                    if err then console.log error.reason
                    else
                        template.uploading.set false
                        alert 'Upload complete!', 'success', 'growl-top-right'