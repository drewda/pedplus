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
    # TODO: do something like MapEditsController
    params[:count_plan].delete 'cid'

    @count_plan = CountPlan.new params[:count_plan]
    
    respond_to do |format|
      if @count_plan.save
        format.json  { render :json => @count_plan, :status => :created, :location => api_project_count_plan_url(@count_plan.project, @count_plan) }
      else
        format.json  { render :json => @count_plan.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    params[:count_plan].delete 'cid'
    
    @count_plan = CountPlan.find(params[:id])

    if counts = params[:counts]
      counts.each do |c|
        count = Count.create(:at => c[:at],
                             :count_plan_id => c[:count_plan_id])
      end
    end

    respond_to do |format|
      if @count_plan.update_attributes(params[:count_plan])
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