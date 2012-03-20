class Api::GateGroupsController < Api::ApiController
  def index
    @gate_groups = GateGroup.where :count_plan_id => params[:count_plan_id]
    # raise ActionController::RoutingError.new('Not Found') if @gate_groups.length == 0
    
    respond_to do |format|
      format.json { render :json => @gate_groups }
    end
  end
  
  def show
    @gate_group = GateGroup.where :id => params[:id], 
                                  :count_plan_id => params[:count_plan_id]
    
    respond_to do |format|
      format.json { render :json => @gate_group }
    end
  end
  
  def create
    @gate_group = GateGroup.new params[:gate_group]
    @gate_group.count_plan = CountPlan.find!(params[:count_plan_id])
    
    respond_to do |format|
      if @gate_group.save
        format.json  { render :json => @gate_group, :status => :created, :location => api_gate_group_url(@gate_group) }
      else
        format.json  { render :json => @gate_group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @gate_group = GateGroup.where! :id => params[:id], 
                                   :count_plan_id => params[:count_plan_id]

    respond_to do |format|
      if @gate_group.update_attributes(params[:gate_group])
        format.json  { render :json => @gate_group }
      else
        format.json  { render :json => @gate_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @gate_group = GateGroup.find(params[:id])
    @gate_group.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
  
end