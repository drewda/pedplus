class Manage::ProjectsController < Manage::ManageController
  def index
    @organization = current_user.organization
    @projects = @organization.projects
  end
  
  def new
    # limit the number of projects that can be created
    if current_user.organization.projects.length < current_user.organization.max_number_of_projects 
      @project = Project.new
    else
      flash[:warning] = "Your organization has no remaining project credits. Please contact S3Sol to upgrade your account."
      redirect_to manage_root_url
    end
  end
  
  def show
    @project = Project.find(params[:id])

    # do not show projects outside of current user's organization
    if @project.organization != current_user.organization
      redirect_to manage_root_url
    end
  end
  
  def edit
    @project = Project.find(params[:id])
    # do not allow editing for projects outside of current user's organization
    if @project.organization != current_user.organization
      redirect_to manage_root_url
    end
  end
  
  def create
    @project = Project.new(params[:project])
    @project.organization = current_user.organization
    @project.max_number_of_counting_locations = current_user.organization.default_max_number_of_counting_locations_per_project

    respond_to do |format|
      if @project.save
        flash[:success] = "<strong>#{@project.name}</strong> project created."
        format.html { redirect_to(edit_manage_project_url(@project)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @project = Project.find(params[:id])
    # do not allow updating for projects outside of current user's organization
    if @project.organization != current_user.organization
      redirect_to manage_root_url
    end

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:success] = "<strong>#{@project.name}</strong> project updated."
        format.html { redirect_to(manage_project_url(@project)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @project = Project.find(params[:id])
    # do not allowing deleting projects outside of current user's organization
    if @project.organization != current_user.organization
      redirect_to manage_root_url
    end
    @project.destroy

    respond_to do |format|
      flash[:success] = "<strong>#{@project.name}</strong> project deleted."
      format.html { redirect_to(manage_projects_url) }
    end
  end
end