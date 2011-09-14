class Api::GeoPointsController < Api::ApiController
  def index
    @geo_points = GeoPoint.all
    
    respond_to do |format|
      format.json { render :json => @geo_points.to_json(:include => [:geo_point_on_segments]) }
    end
  end
end