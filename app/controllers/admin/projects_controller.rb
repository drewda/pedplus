class Admin::ProjectsController < Admin::AdminController
  def index
    @projects = Organization.find(params[:organization_id]).projects
  end
  
  def new
    @project = Project.new
    @project.organization = Organization.find(params[:organization_id])
  end
  
  def show
    @project = Organization.find(params[:organization_id]).projects.find(params[:id])
  end
  
  def edit
    @project = Organization.find(params[:organization_id]).projects.find(params[:id])
  end
  
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        @project.update_attribute :max_number_of_gates, @project.organization.default_max_number_of_gates_per_project
        flash[:success] = "<strong>#{@project.name}</strong> project created."
        format.html { redirect_to(admin_organization_project_url(@project.organization, @project)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:success] = "<strong>#{@project.name}</strong> project updated."
        format.html { redirect_to(admin_organization_project_url(@project.organization, @project)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      flash[:success] = "<strong>#{@project.name}</strong> project deleted."
      format.html { redirect_to(admin_organization_url(@project.organization)) }
    end
  end
end