let map;

function initMap() {
    // Create map element
    map = new google.maps.Map(document.getElementById("map"), {
        center: { lat: -34.397, lng: 150.644 },
        zoom: 8,
    });

    // Create search box
    var searchBox = new google.maps.places.SearchBox(document.getElementById('pac-input'));
    // Center search box
    map.controls[google.maps.ControlPosition.TOP_CENTER].push(document.getElementById('pac-input'));
    
    // Add event listener to searchbox
    google.maps.event.addListener(searchBox, 'places_changed', function() {
        searchBox.set('map', null);

        // Get array of several predictions for places
        var places = searchBox.getPlaces();
        
        // TODO: Add filter so we only search results within midwest
        // Use Autocomplete widget
        //https://developers.google.com/maps/documentation/javascript/place-autocomplete#add-autocomplete
        // Create bounds object
        var bounds = new google.maps.LatLngBounds();
        var i, place;
        // Loop through all places
        for (i = 0; place = places[i]; i++) {
            (
                function(place) {
                    // Create marker from place locaton
                    var marker = new google.maps.Marker({
                        position: place.geometry.location
                    });
                    // Bias results to map viewport
                    marker.bindTo('map', searchBox, 'map');
                    // Unbind if map changes
                    google.maps.event.addListener(marker, 'map_changed', function() {
                    if (!this.getMap()) {
                        this.unbindAll();
                    }
                    });
                    // Extend bounds to include place location
                    bounds.extend(place.geometry.location);
                }(place) // Call function on each place
            );

        }
        // Set viewport to contain given bounds
        map.fitBounds(bounds);
        // Renders searchbox on map?
        searchBox.set('map', map);
        // Sets map zoom
        map.setZoom(Math.min(map.getZoom(),12));

    });


}

window.initMap = initMap;