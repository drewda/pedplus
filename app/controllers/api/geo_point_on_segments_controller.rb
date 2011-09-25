class Api::GeoPointOnSegmentsController < Api::ApiController
  def index
    @geo_point_on_segments = GeoPointOnSegment.where(:project_id => params[:project_id])
    
    respond_to do |format|
      format.json { render :json => @geo_point_on_segments }
    end
  end
  
  def show
    @geo_point_on_segment = GeoPointOnSegment.find(:conditions => ["id = ? and project_id = ?", params[:id], params[:project_id]])
    
    respond_to do |format|
      format.json { render :json => @geo_point_on_segment }
    end
  end
  
  def create
    @geo_point_on_segment = GeoPointOnSegment.new params[:geo_point_on_segment]
    @geo_point_on_segment.project = Project.find(params[:project_id])
    
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
    @geo_point_on_segment = Project.find([:project_id]).geo_point_on_segments

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
    @geo_point_on_segment = GeoPointOnSegment.where(:id => params[:id], :project_id => params[:project_id])
    @geo_point_on_segment.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
  
end