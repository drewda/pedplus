class Api::ProjectsController < Api::ApiController
  def index
    @projects = current_user.projects
    
    respond_to do |format|
      format.json { render :json => @projects }
    end
  end
end