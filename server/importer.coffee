Meteor.methods
    create_importer: ->
        id = Importers.insert
            tags: []
            timestamp: Date.now()
            authorId: Meteor.userId()
            username: Meteor.user().username
        return id

    save_importer: (id, url, method)->
        Importers.update id,
            $set:
                url: url
                method: method

    run_importer: (id)->
        importer = Importers.findOne id
        HTTP.call importer.method, importer.url, {}, (err, result)->
            if err then console.error err
            else
                parsedContent = JSON.parse result.content

                features = parsedContent.features
                # console.log features[0].properties
                newDocs = (feature.properties for feature in features)
                for doc in newDocs
                    id = Docs.insert
                        body: doc.CASE_DESCR
                        authorId: Meteor.userId()
                        timestamp: Date.now()
                        tags: ['boulder permits', doc.STAFF_EMAI?.toLowerCase(), doc.STAFF_PHON?.toLowerCase(), doc.STAFF_CONT?.toLowerCase(), doc.CASE_NUMBE?.toLowerCase(), doc.CASE_TYPE?.toLowerCase(), doc.APPLICANT_?.toLowerCase(), doc.CASE_ADDRE?.toLowerCase()]
                    Meteor.call 'analyze', id, true



Meteor.publish 'importers', -> Importers.find { authorId: @userId}

Meteor.publish 'importer', (id)-> Importers.find id


Importers.allow
    insert: (userId, doc)-> doc.authorId is Meteor.userId()
    update: (userId, doc)-> doc.authorId is Meteor.userId()
    remove: (userId, doc)-> doc.authorId is Meteor.userId()


