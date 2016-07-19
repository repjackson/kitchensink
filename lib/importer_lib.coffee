@Importers = new Meteor.Collection 'importers'


Meteor.methods
    updateFieldType: (id, fieldName, selection)->
        # direct tag
        # time/date
        # geo
        # skip
        Importers.update {
            _id: id
            fieldsObject: $elemMatch:
                name: fieldName
            }, $set: 'fieldsObject.$.type': selection

    toggleFieldTag: (id, fieldName, value)->
        Importers.update {
            _id: id
            fieldsObject: $elemMatch:
                name: fieldName
            }, $set: 'fieldsObject.$.tag': value




FlowRouter.route '/importers', action: (params) -> BlazeLayout.render 'layout', main: 'importer_list'

FlowRouter.route '/importers/:iId', action: (params) -> BlazeLayout.render 'layout', main: 'importer_view'

