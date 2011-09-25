class Api::ProjectsController < Api::ApiController
  def index
    @projects = current_user.projects
    
    respond_to do |format|
      format.json { render :json => @projects.to_json(:methods => [:geographic_center]) }
    end
  end
end