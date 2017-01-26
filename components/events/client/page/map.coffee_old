Meteor.startup ->
    GoogleMaps.load({key: 'AIzaSyA-U_RcUcDw1aOoMJXpPcjlWj0VtwVqCTk' })


Template.map.helpers 
    exampleMapOptions: ->
        # Make sure the maps API has loaded
        if GoogleMaps.loaded()
            # Map initialization options
            address = Template.parentData().venue.address
            return {
                center: new (google.maps.LatLng)(address.latitude, address.longitude)
                zoom: 15
            }


Template.map.onCreated ->
    # We can use the `ready` callback to interact with the map API once the map is ready.
    GoogleMaps.ready 'exampleMap', (map) ->
        # Add a marker to the map once it's ready
        marker = new (google.maps.Marker)(
            position: map.options.center
            map: map.instance)
