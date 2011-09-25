class Api::MapEditsController < Api::ApiController
  def upload    
    geoPoints = params['geo_points']
    segments = params['segments']
    geoPointOnSegments = params['geo_point_on_segments']
    
    # TODO: handle local deletes
    
    geoPoints.each do |gpLocal|
      if gpLocal['id']
        cid = gpLocal.delete 'cid'
        GeoPoint.find(gpLocal['id']).update gpLocal # TODO: check
      else
        cid = gpLocal.delete 'cid'
        gpServer = GeoPoint.create gpLocal
        gpLocal['id'] = gpServer.id
        gpLocal['cid'] = cid
      end
    end
    segments.each do |sLocal|
      if sLocal['id']
        cid = sLocal.delete 'cid'
        Segment.find(sLocal['id']).update sLocal # TODO: check
      else
        cid = sLocal.delete 'cid'
        sServer = Segment.create sLocal
        sLocal['id'] = sServer.id
        sLocal['cid'] = cid
      end
    end
    geoPointOnSegments.each do |gposLocal|
      # TODO: check to see if it's new or old
      geoPointId = geoPoints.find { |gp| gp['cid'] == gposLocal['geo_point_cid'] }['id']
      segmentId = segments.find { |s| s['cid'] == gposLocal['segment_cid'] }['id']
      GeoPointOnSegment.create geo_point_id: geoPointId, segment_id: segmentId, project_id: gposLocal['project_id']
    end
    
    json = {
      geoPoints: geoPoints,
      segments: segments,
      geoPointOnSegments: geoPointOnSegments
    }
    
    respond_to do |format|
      format.json { render :json => json }
    end
  end
end