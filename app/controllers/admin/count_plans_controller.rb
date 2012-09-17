class Admin::CountPlansController < Admin::AdminController
  def index
    @project = Project.find(params[:project_id])
    @count_plans = @project.count_plans
  end

  def show
    @project = Project.find(params[:project_id])
    @count_plan = @project.count_plans.find(params[:id])
  end
  
  def edit
    @project = Project.find(params[:project_id])
    @count_plan = @project.count_plans.find(params[:id])
  end
  
  def update
    @project = Project.find(params[:project_id])
    @count_plan = @project.count_plans.find(params[:id])

    respond_to do |format|
      if @count_plan.update_attributes(params[:count_plan])
        flash[:success] = "Count plan updated."
        format.html { redirect_to(admin_organization_project_count_plans_url(@project.organization, @project)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @project = Project.find(params[:project_id])
    @count_plan = @project.count_plans.find(params[:id])
    @count_plan.destroy

    respond_to do |format|
      flash[:success] = "Count plan deleted."
      format.html { redirect_to(admin_organization_project_count_plans_url(@project.organization)) }
    end
  end
end
