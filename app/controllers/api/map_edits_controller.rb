class Api::MapEditsController < Api::ApiController
  def upload    
    geoPoints = params['geo_points']
    segments = params['segments']
    geoPointOnSegments = params['geo_point_on_segments']
    
    geoPoints.each do |gpLocal|
      if gpLocal['id']
        if gpLocal['markedForDelete']
          GeoPoint.find(gpLocal['id']).delete
        else
          cid = gpLocal.delete 'cid'
          GeoPoint.find(gpLocal['id']).update_attributes gpLocal # TODO: check
        end
      else
        if !gpLocal['markedForDelete']
          cid = gpLocal.delete 'cid'
          gpServer = GeoPoint.create gpLocal
          gpLocal['id'] = gpServer.id
          gpLocal['cid'] = cid
        end
      end
    end
    segments.each do |sLocal|
      if sLocal['id']
        if sLocal['markedForDelete']
          Segment.find(sLocal['id']).delete
        else
          cid = sLocal.delete 'cid'
          Segment.find(sLocal['id']).update_attributes sLocal # TODO: check
        end
      else
        if !sLocal['markedForDelete']
          cid = sLocal.delete 'cid'
          sServer = Segment.create sLocal
          sLocal['id'] = sServer.id
          sLocal['cid'] = cid
        end
      end
    end
    geoPointOnSegments.each do |gposLocal|
      if gposLocal['geo_point_id'] and gposLocal['markedForDelete']
        GeoPointOnSegment.find(gposLocal['id']).delete
      else
        if !gposLocal['markedForDelete']
          if gposLocal['geo_point_id']
            geoPointId = gposLocal['geo_point_id']
          elsif gposLocal['geo_point_cid']
            geoPointId = geoPoints.find { |gp| gp['cid'] == gposLocal['geo_point_cid'] }['id']
          end
          segmentId = segments.find { |s| s['cid'] == gposLocal['segment_cid'] }['id']
          GeoPointOnSegment.create geo_point_id: geoPointId, segment_id: segmentId, project_id: gposLocal['project_id']
        end
      end
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