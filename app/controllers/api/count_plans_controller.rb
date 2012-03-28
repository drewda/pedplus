class Api::CountPlansController < Api::ApiController
  def index
    @count_plans = CountPlan.where(:project_id => params[:project_id])
    
    respond_to do |format|
      format.json { render :json => @count_plans.to_json(:methods => [:percent_completed, :end_date]) }
    end
  end
  
  def show
    @count_plan = CountPlan.where(:id => params[:id], :project_id => params[:project_id])
    
    respond_to do |format|
      format.json { render :json => @count_plan.to_json(:methods => [:percent_completed, :end_date]) }
    end
  end
  
  def create
    if params[:gateGroups]
      gateGroups = params.delete 'gateGroups'
      gateGroupCidToIdHash = Hash.new
    end
    if params[:gates]
      gates = params.delete 'gates'
    end

    @count_plan = CountPlan.new pick(params, :project_id, :start_date, :count_session_duration_seconds, :total_weeks, :is_the_current_plan)
    
    respond_to do |format|
      if @count_plan.save
        if gateGroups
          gateGroups.each do |ggLocal|
            gateGroup = GateGroup.create :count_plan_id => @count_plan.id,
                                         :label => ggLocal[:label],
                                         :days => ggLocal[:days],
                                         :hours => ggLocal[:hours],
                                         :status => ggLocal[:status],
                                         :user_id => ggLocal[:user_id]
            gateGroupCidToIdHash[ggLocal[:cid]] = gateGroup.id
          end
        end
        if gates
          gates.each_with_index do |gLocal, index|
            gate = Gate.create :segment_id => gLocal[:segment_id],
                               :gate_group_id => gateGroupCidToIdHash[gLocal[:gate_group_cid]],
                               :count_plan_id => @count_plan.id,
                               :counting_days_remaining => @count_plan.project.organization.default_counting_days_per_gate,
                               :label => index + 1
          end
        end

        format.json  { render :json => @count_plan, :status => :created, :location => api_project_count_plan_url(@count_plan.project, @count_plan) }
      else
        format.json  { render :json => @count_plan.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    # TODO: make this work the same as create    
    @count_plan = CountPlan.find(params[:id])

    respond_to do |format|
      if @count_plan.update_attributes pick(params, :is_the_current_plan)
        format.json  { render :json => @count_plan }
      else
        format.json  { render :json => @count_plan.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @count_plan = CountPlan.find(params[:id])
    @count_plan.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
end