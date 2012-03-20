class Api::GateGroupSchedulesController < Api::ApiController
  def index
    @json = []
    # TODO: datetime, status, user_id, gate_group_id
    
    respond_to do |format|
      format.json { render :json => @json }
    end
  end
end