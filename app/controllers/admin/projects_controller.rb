class Admin::ProjectsController < Admin::AdminController
  def index
    @projects = Project.all
  end
  
  def new
    @project = Project.new
  end
  
  def show
    @project = Project.find(params[:id])
  end
  
  def edit
    @project = Project.find(params[:id])
  end
  
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        flash[:success] = "<strong>#{@project.name}</strong> project created."
        format.html { redirect_to(admin_project_url(@project)) }
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
        format.html { redirect_to(admin_project_url(@project)) }
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
      format.html { redirect_to(admin_projects_url) }
    end
  end
end