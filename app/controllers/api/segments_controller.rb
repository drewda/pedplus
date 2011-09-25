class Api::SegmentsController < Api::ApiController
  def index
    @segments = Segment.where(:project_id => params[:project_id])
    
    respond_to do |format|
      format.json { render :json => @segments.to_json(:include => [:geo_point_on_segments]) }
    end
  end
  
  def show
    @segment = Segment.find(:conditions => ["id = ? and project_id = ?", params[:id], params[:project_id]])
    
    respond_to do |format|
      format.json { render :json => @segment.to_json(:include => [:geo_point_on_segments]) }
    end
  end
  
  def create
    @segment = Segment.new params[:segment]
    @segment.project = Project.find(params[:project_id])
    
    respond_to do |format|
      if @segment.save
        flash[:notice] = 'Segment was successfully created.'
        format.json  { render :json => @segment, :status => :created, :location => api_segment_url(@segment) }
      else
        format.json  { render :json => @segment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @segment = Segment.find(:conditions => ["id = ? and project_id = ?", params[:id], params[:project_id]])

    respond_to do |format|
      if @segment.update_attributes(params[:segment])
        flash[:notice] = 'Segment was successfully updated.'
        format.json  { render :json => @segment }
      else
        format.json  { render :json => @segment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @segment = Segment.find(:conditions => ["id = ? and project_id = ?", params[:id], params[:project_id]])
    @segment.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
  
end