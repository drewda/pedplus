class Api::ProjectsController < Api::ApiController
  def index
    @projects = current_user
    
    respond_to do |format|
      format.json { render :json => @ped_projects }
    end
  end
end