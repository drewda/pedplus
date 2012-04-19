class Api::ProjectsController < Api::ApiController
  # note that the tablet app will usually load the json for projects
  # by way of app_controller.rb and the injectProjects() function in app.slim
  def index
    @projects = current_user.viewable_projects

    # kludge!
    @projects.each do |p|
      p.current_user = current_user
    end

    respond_to do |format|
      format.json { render :json => @projects.to_json(:methods => [:permissions_for_current_user]) }
    end
  end

  def show
    # TODO: permissions
    @project = Project.find params[:id]
  end

  def update
    # TODO: permissions
    @project = Project.find params[:id]

    respond_to do |format|
      if @project.update_attributes pick(params, :base_map, :name)
        format.json  { render :json => @project }
      else
        format.json  { render :json => @project.errors, :status => :unprocessable_entity }
      end
    end
  end
end