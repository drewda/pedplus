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
    params[:count_plan].delete 'cid'

    if params[:count_plan][:users]
      countPlanUserIds = params[:count_plan].delete 'users'
      countPlanUserIds = countPlanUserIds.split ','
    end
    if params[:count_plan][:segments]
      segmentIds = params[:count_plan].delete 'segments'
      segmentIds = segmentIds.split ','
    end

    @count_plan = CountPlan.new params[:count_plan]
    
    respond_to do |format|
      if @count_plan.save
        countPlanUserIds.each { |userId| CountPlanUser.create :count_plan_id => @count_plan.id, :user_id => userId }
        segmentIds.each { |segmentId| CountPlanSegment.create :count_plan_id => @count_plan.id, :segment_id => segmentId }

        # TODO: create the CountSessions

        format.json  { render :json => @count_plan, :status => :created, :location => api_project_count_plan_url(@count_plan.project, @count_plan) }
      else
        format.json  { render :json => @count_plan.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
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