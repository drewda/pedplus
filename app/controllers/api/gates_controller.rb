class Api::GatesController < Api::ApiController
  def index
    @gates = Gate.where :count_plan_id => params[:count_plan_id]
    # raise ActionController::RoutingError.new('Not Found') if @gates.length == 0
    
    respond_to do |format|
      format.json { render :json => @gates }
    end
  end
  
  def show
    @gate = Gate.where :id => params[:id], 
                       :count_plan_id => params[:count_plan_id]
    
    respond_to do |format|
      format.json { render :json => @gate }
    end
  end
  
  def create
    @gate = Gate.new params[:gate]
    @gate.count_plan = CountPlan.find!(params[:count_plan_id])
    
    respond_to do |format|
      if @gate.save
        format.json  { render :json => @gate, :status => :created, :location => api_gate_url(@gate) }
      else
        format.json  { render :json => @gate.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @gate = Gate.where! :id => params[:id], 
                        :count_plan_id => params[:count_plan_id]

    respond_to do |format|
      if @gate.update_attributes(params[:gate])
        format.json  { render :json => @gate }
      else
        format.json  { render :json => @gate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @gate = Gate.find(params[:id])
    @gate.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
  
end