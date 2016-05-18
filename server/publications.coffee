Meteor.publish 'authored_intersection_tags', (authorId)->
    author_list = Meteor.users.findOne(authorId).authored_list
    author_tags = Meteor.users.findOne(authorId).authored_cloud

    your_list = Meteor.user().authored_list
    your_tags = Meteor.user().authored_cloud

    list_intersection = _.intersection(author_list, your_list)

    intersection_tags = []
    for tag in list_intersection
        author_count = author_tags.tag.count
        your_count = your_tags.tag.count
        lower_value = Meth.min(author_count, your_count)
        cloud_object = name: tag, count: lower_value
        intersection_tags.push cloud_object

    console.log intersection_tags

    intersection_tags.forEach (tag) ->
        self.added 'authored_intersection_tags', Random.id(),
            name: tag.name
            count: tag.count

    self.ready()
