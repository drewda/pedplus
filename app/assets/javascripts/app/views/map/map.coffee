class App.Views.Map extends Backbone.View
  initialize: ->
    @render()
  render: ->
    window.po = org.polymaps
 
    window.map = po.map()
       .container(document.getElementById("map-area").appendChild(po.svg("svg")))
       .add(po.interact())

    osmLayer = po.image()
                .url(po.url('''http://{S}tile.cloudmade.com
                /b8f01ac08d4242be9c2876f862c8ef2c
                /997/256/{Z}/{X}/{Y}.png''')
                .hosts(["a.", "b.", "c.", ""]))
                .id("osm-layer")
    map.add(osmLayer)

    map.add(po.compass()
            .pan("none"))
            
    @centerMapAtCurrentPosition()
  centerMapAtCurrentPosition: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        map.center
          lat: position.coords.latitude
          lon: position.coords.longitude
        map.zoom 16