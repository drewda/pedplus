class Api::GeoPointsController < Api::ApiController
  def index
    @geo_points = GeoPoint.where(:project_id => params[:project_id])
    # raise ActionController::RoutingError.new('Not Found') if @geo_points.length == 0
    
    respond_to do |format|
      format.json { render :json => @geo_points }
    end
  end
  
  def show
    @geo_point = GeoPoint.where(:id => params[:id], :project_id => params[:project_id])
    
    respond_to do |format|
      format.json { render :json => @geo_point }
    end
  end
  
  def create
    @geo_point = GeoPoint.new params[:geo_point]
    @geo_point.project = Project.find!(params[:project_id])
    
    respond_to do |format|
      if @geo_point.save
        flash[:notice] = 'GeoPoint was successfully created.'
        format.json  { render :json => @geo_point, :status => :created, :location => api_geo_point_url(@geo_point) }
      else
        format.json  { render :json => @geo_point.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @geo_point = GeoPoint.where!(:id => params[:id], :project_id => params[:project_id])

    respond_to do |format|
      if @geo_point.update_attributes(params[:geo_point])
        flash[:notice] = 'GeoPoint was successfully updated.'
        format.json  { render :json => @geo_point }
      else
        format.json  { render :json => @geo_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @geo_point = GeoPoint.find(params[:id])
    @geo_point.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
  
end