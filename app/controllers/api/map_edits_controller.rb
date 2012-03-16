class Api::MapEditsController < Api::ApiController
  def upload    
    projectId = params['map_edit']['project_id'] # we're assuming uploads are for only one project
    geoPoints = params['map_edit']['geo_points']
    segments = params['map_edit']['segments']
    geoPointOnSegments = params['map_edit']['geo_point_on_segments']
    
    # remove the root elements from Backbone's JSON 
    geoPoints = geoPoints.map { |gp| gp['geo_point'] }
    segments = segments.map { |s| s['segment'] }
    geoPointOnSegments = geoPointOnSegments.map { |gpos| gpos['geo_point_on_segment'] }

    # Backbone shouldn't be sending all of this, but for now it is, 
    # so we want to ignore these extra attributes
    ['selected', 'moved', 'permeabilityValue', 'permeabilityClass', 'measuredClass'].each do |attr|
      geoPoints.map! { |gp| gp.except attr }
      segments.map! { |s| s.except attr }
    end
    
    geoPoints.each do |gpLocal|
      if gpLocal['id']
        if gpLocal['markedForDelete']
          GeoPoint.find(gpLocal['id']).destroy
        else
          cid = gpLocal.delete 'cid'
          GeoPoint.find(gpLocal['id']).update_attributes gpLocal
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
          # the segment may be deleted when a geopoint is destroyed, but just
          # in case we will check to see if it still needs to be deleted
          s = Segment.find_by_id(sLocal['id'])
          if s
            s.destroy
          end
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
        # the gpos will probably be deleted when the segment is destroyed,
        # but just in case we will check to see if it still needs to be deleted
        gpos.destroy if gpos = GeoPointOnSegment.find_by_id(gposLocal['id'])
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
    
    project = Project.find(projectId)

    # remove any disconnected segments from project
    project.remove_broken_segments()
    
    # update project's bounding box
    # we'll assume that data is only being uplaoded for one project
    project.cache_bounding_box if geoPoints.length > 0
    
    # increment the project's version
    project.increment!(:version)
    
    # json to return
    json = {
      projectId: projectId,
      projectVersion: project.version,
      geoPoints: geoPoints,
      segments: segments,
      geoPointOnSegments: geoPointOnSegments
    }
    
    respond_to do |format|
      format.json { render :json => json }
    end
  end
end