class Api::SegmentsController < Api::ApiController
  def index
    @segments = Segment.all
    
    respond_to do |format|
      format.json { render :json => @segments.to_json(:include => [:geo_point_on_segments]) }
    end
  end
end