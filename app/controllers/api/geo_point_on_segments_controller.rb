class Api::GeoPointOnSegmentsController < Api::ApiController
  def index
    @geo_point_on_segment = GeoPointOnSegment.all
    
    respond_to do |format|
      format.json { render :json => @geo_point_on_segment }
    end
  end
end