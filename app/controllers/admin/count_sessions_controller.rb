class Admin::CountSessionsController < Admin::AdminController
  def index
    @project = Project.find(params[:project_id])
    @count_sessions = @project.count_sessions
  end

  def show
    @project = Project.find(params[:project_id])
    @count_session = @project.count_sessions.find(params[:id])
  end
  
  def edit
    @project = Project.find(params[:project_id])
    @count_session = @project.count_sessions.find(params[:id])
  end
  
  def update
    @project = Project.find(params[:project_id])
    @count_session = @project.count_sessions.find(params[:id])

    respond_to do |format|
      if @count_session.update_attributes(params[:count_session])
        flash[:success] = "Count session updated."
        format.html { redirect_to(admin_organization_project_count_sessions_url(@project.organization, @project)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @project = Project.find(params[:project_id])
    @count_session = @project.count_sessions.find(params[:id])
    @count_session.destroy

    respond_to do |format|
      flash[:success] = "Count session (and all its counts) deleted."
      format.html { redirect_to(admin_organization_project_count_sessions_url(@project.organization)) }
    end
  end
end
