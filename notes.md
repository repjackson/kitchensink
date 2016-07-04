db.docs.find().forEach(function(item)
{
    var tag_count = item.tags.length;
    item.tag_count = tag_count;
    db.docs.save(item);
})


db.docs.update({
      }, {
        $set: {
          "tag_count": 
        }
      },
      function(err) {
        if (err) console.log(err);
      }
    );
  })


db.docs.find({}).forEach(
  function(doc) {
    var tag_count = doc.tags.length;
    doc.tag_count = tag_count;
    db.docs.save(doc);
  }
)


<!--autocomplete add tag to doc-->
<!--bookmarks-->
<!--cancel edit option-->
<!--shareable address-->
<!--me button-->

logan version
<!--generate cloud after update-->
matched users
take in filter
find all users with tag in tag cloud
from that set find all users with matching tags in tag list
filter tags 