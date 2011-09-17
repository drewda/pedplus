class Api::GeoPointOnSegmentsController < Api::ApiController
  def index
    @geo_point_on_segments = GeoPointOnSegment.all
    
    respond_to do |format|
      format.json { render :json => @geo_point_on_segments }
    end
  end
  
  def create
    @geo_point_on_segment = GeoPointOnSegment.new params[:geo_point_on_segment]
    
    respond_to do |format|
      if @geo_point_on_segment.save
        flash[:notice] = 'GeoPointOnSegment was successfully created.'
        format.json  { render :json => @geo_point_on_segment, :status => :created, :location => api_geo_point_on_segment_url(@geo_point_on_segment) }
      else
        format.json  { render :json => @geo_point_on_segment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @geo_point_on_segment = GeoPointOnSegment.find(params[:id])

    respond_to do |format|
      if @geo_point_on_segment.update_attributes(params[:geo_point_on_segment])
        flash[:notice] = 'GeoPointOnSegment was successfully updated.'
        format.json  { head :ok }
      else
        format.json  { render :xml => @geo_point_on_segment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @geo_point_on_segment = GeoPointOnSegment.find(params[:id])
    @geo_point_on_segment.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
  
end