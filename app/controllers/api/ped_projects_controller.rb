class Api::PedProjectsController < Api::ApiController
  def index
    @ped_projects = PedProject.all
    
    respond_to do |format|
      format.json { render :json => @ped_projects }
    end
  end
end