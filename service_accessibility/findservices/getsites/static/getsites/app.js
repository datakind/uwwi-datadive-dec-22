// Get site data
// NOTE: Seems there are duplicate sites --> TODO: remove these in cleaning script
// TODO: Check on 'ZZZInactive'site names
// TODO: Add drop down menu to query sites for a specific service category (eg food, medical, counseling, etc)
// TODO: Add drop down menu to query based on travel type (eg walking, biking, cycling)
const data = document.currentScript.dataset;
const sites = JSON.parse(data.sites);
const numSites = Object.keys(sites).length;

// Initialize variable to store web map
let map;
// Initialize variables for storing location data
let site;
let sitePt;

// Sorting function to use for comparing straight line distances from start point
function sortByDist(a, b) {
    return (a.distance - b.distance)
}

// Sorting function to use for comparing travel distances from start point
function sortByTravelDist(a, b) {
    return (a.travel_dist - b.travel_dist)
}

// Function to calculate distance as the crow flies to all sites from start point, and return only the closest N sites
function findClosestN(pt, n) {
    var allSites = [];
    var closest = [];
    //document.getElementById('info').innerHTML += "processing "+gmarkers.length+"<br>";
    for (var i = 0; i < numSites; i++) {
        site = Object.values(sites)[i];
        sitePt = {lat: site.site_lat, lng: site.site_long};
        // computeDistanceBetween() returns distances in meters
        site.distance = google.maps.geometry.spherical.computeDistanceBetween(pt, sitePt);
        //document.getElementById('info').innerHTML += "process " + i + ":" + sites.getPosition().toUrlValue(6) + ":" + sites.distance.toFixed(2) + "<br>";
        //sites.setMap(null);
        allSites.push(site);
    }
    // Sort closest sites by straight line distance and get 'N' closest sites
    closest = allSites.sort(sortByDist).slice(0, n);
    return closest;
}

// Function to calculate travel distance to sites from a given start point
// Add the travel distances to site attributes
// Sort the calculated distances by travel distance
// Retrieve the 'N' closest sites by travel distance
// Add the closest 'N' sites to the map
// Add popups (info windows) to display info about sites
// Note: this function involves making a request so have to 
// wait until request is ready to use the output data
function calculateDistances(pt, closest, numResults, m, searchB, mapB) {
    // Get user-specified travel mode from dropdown input
    const selectedMode = document.getElementById("mode").value;
    // Create distance matrix serivce object and specify parameters
    var service = new google.maps.DistanceMatrixService();
    var request = {
        origins: [pt],
        destinations: [],
        //travelMode: google.maps.TravelMode.DRIVING,
        travelMode: google.maps.TravelMode[selectedMode],
        //unitSystem: google.maps.UnitSystem.METRIC,
        unitSystem: google.maps.UnitSystem.IMPERIAL,
        avoidHighways: false,
        avoidTolls: false
    };
    for (var i = 0; i < closest.length; i++) {
        request.destinations.push({lat: closest[i].site_lat, lng: closest[i].site_long});
    }
    
    service.getDistanceMatrix(request, function (response, status) {
        if (status != google.maps.DistanceMatrixStatus.OK) {
            alert('Error was: ' + status);
        } else {
            var origins = response.originAddresses;
            var destinations = response.destinationAddresses;
            //var outputDiv = document.getElementById('side_bar');
            //outputDiv.innerHTML = '';
            var results = response.rows[0].elements;

            // Add the calculated travel distances and durations to the site attributes
            for (var i = 0; i < closest.length; i++) {
                closest[i].travel_dist = results[i].distance.value;
                closest[i].travel_dist_text = results[i].distance.text;
                closest[i].travel_time = results[i].duration.value;
                closest[i].travel_time_text = results[i].duration.text;
                //outputDiv.innerHTML += "<a href='javascript:google.maps.event.trigger(closest[" + i + "],\"click\");'>" + closest[i].title + '</a><br>' + closest[i].address + "<br>"
                //    + results[i].distance.text + ' appoximately '
                //    + results[i].duration.text + '<br><hr>';
            }

            // Sort based on travel distance and extract N closest items
            closest = closest.sort(sortByTravelDist).slice(0, numResults);

            // Map the results
            for (var i in closest) {
                const contentString =
                    '<div id="content">' +
                    '<h1 id="firstHeading" class="firstHeading">' + closest[i].SiteSystem_Name + '</h1>' +
                    '<div id="bodyContent">' +
                    '<p> Travel distance: ' + closest[i].travel_dist_text + '<br>' +
                    ' Travel time: ' + closest[i].travel_time_text + '</p>' +
                    '</div>' +
                    '</div>';

                const infowindow = new google.maps.InfoWindow({
                    content: contentString,
                    //ariaLabel: closest[i].SiteSystem_Name,
                    position: {lat: closest[i].site_lat, lng: closest[i].site_long},
                });

                // Create marker from location
                var marker = new google.maps.Marker({
                    position: {lat: closest[i].site_lat, lng: closest[i].site_long},
                    //icon: {url: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"},
                    icon: {
                        path: google.maps.SymbolPath.BACKWARD_CLOSED_ARROW,
                        strokeColor: "#8c38d1",
                        scale: 9,
                    },
                });

                // Add listener to display info window on click event
                marker.addListener("click", () => {
                    infowindow.open({
                      maxWidth: 50,
                      map: m,
                    });
                  });

                // Bias results to map viewport
                marker.bindTo('map', searchB, 'map');
                // Unbind if map changes
                google.maps.event.addListener(marker, 'map_changed', function() {
                    if (!this.getMap()) {
                        this.unbindAll();
                    }
                });
                // Extend bounds to include place location
                mapB.extend(marker.position);

                // Add marker to the map
                //marker.setMap(m);
            } // endfor

            m.fitBounds(mapB);
            map.setZoom(Math.min(m.getZoom(),15));

            
        }
    });
}

// Function to filter out close services by straight line distance,
// and then calculate travel distance for the services
// Takes map object so we can render the results
function findServices(pt, m, searchB, mapB) {
    let startCoords = {lat: pt.lat(), lng: pt.lng()};
    let closestByStraightLine = findClosestN(pt, 10);
    // Note that calculateDistance involves waiting for a response
    calculateDistances(startCoords, closestByStraightLine, 3, m, searchB, mapB);
}

// Function to set up web map
// Add search bar with autocomplete for address inputs
// Get N closest sites by travel distance based on user input address
// Map the N closest sites on the map
function initMap() {
    // Create map element
    map = new google.maps.Map(document.getElementById("map"), {
        center: { lat: 44.610547, lng: -89.697035 },
        zoom: 7,
    });

    // Create search box
    var searchBox = new google.maps.places.SearchBox(document.getElementById('pac-input'));
    // Center search box
    map.controls[google.maps.ControlPosition.TOP_RIGHT].push(document.getElementById('pac-input'));
    
    // Add event listener to searchbox
    google.maps.event.addListener(searchBox, 'places_changed', function() {
        searchBox.set('map', null);

        // Get array of several predictions for places
        var places = searchBox.getPlaces();
        
        // Maybe want to use Autocomplete widget in future (can add geographic filters)?
        //https://developers.google.com/maps/documentation/javascript/place-autocomplete#add-autocomplete
        // Create bounds object
        var bounds = new google.maps.LatLngBounds();
        var i, place;
        // Loop through all places
        for (i = 0; place = places[i]; i++) {
            (
                function(place) {

                    // Get nearby services for the location
                    findServices(place.geometry.location, map, searchBox, bounds);

                    // Create marker from place locaton
                    var marker = new google.maps.Marker({
                        position: place.geometry.location,
                    });
                    /*// Bias results to map viewport
                    marker.bindTo('map', searchBox, 'map');
                    // Unbind if map changes
                    google.maps.event.addListener(marker, 'map_changed', function() {
                    if (!this.getMap()) {
                        this.unbindAll();
                    }
                    });
                    // Extend bounds to include place location
                    bounds.extend(place.geometry.location);*/
                    // Save place
                }(place) // Call function on each place
            );

        }
        // Set viewport to contain given bounds
        //map.fitBounds(bounds);
        // Renders searchbox on map?
        searchBox.set('map', map);
        // Sets map zoom
        //map.setZoom(Math.min(map.getZoom(),15));

    });
}

window.initMap = initMap;