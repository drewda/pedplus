class Smartphone.Views.Map extends Backbone.View
  initialize: ->  
    @map = null
    @osmLayer = null
    
    $('#map-area').empty()
    
    @render()
  render: ->
    window.po = org.polymaps
    @map = po.map()
       .container(document.getElementById("map-area").appendChild(po.svg("svg")))
       # .add(po.drag())
       # .add(po.wheel())
       # .add(po.touch())
    
    @osmLayer = po.image()
      .url(po.url('http://otile{S}.mqcdn.com/tiles/1.0.0/osm/{Z}/{X}/{Y}.png').hosts(["1", "2", "3", "4"]))
      .id("osm-color-layer")
    @map.add(@osmLayer)
    
    @centerMap()

  centerMap: ->
    if currentProject = masterRouter.projects.getCurrentProject()
      if currentProject.get 'southwest_latitude'
        @map.extent [
          lat: currentProject.get 'northeast_latitude'
          lon: currentProject.get 'northeast_longitude'
        ,
          lat: currentProject.get 'southwest_latitude'
          lon: currentProject.get 'southwest_longitude'
        ]
        @map.zoomBy -1
      else
        @centerMapAtCurrentPosition()
    else
      @centerMapAtCurrentPosition()
  centerMapAtCurrentPosition: ->
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        masterRouter.map.map.center
          lat: position.coords.latitude
          lon: position.coords.longitude
        masterRouter.map.map.zoom 16
    else # Berkeley Way
      map.center
        lat: 37.871592
        lon: 122.272747