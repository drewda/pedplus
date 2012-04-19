class Api::CountSessionsController < Api::ApiController
  def index
    @count_sessions = CountSession.where(:project_id => params[:project_id])
    
    respond_to do |format|
      format.json { render :json => @count_sessions.to_json(:methods => [:segment_id, :duration_minutes]) }
      format.csv do
        # use render_csv(), which is defined in api_controller.rb
        render_csv("project-#{params[:project_id]}-count_sessions")
      end
    end
  end
  
  def show
    @count_session = CountSession.find(:id => params[:id])
    
    respond_to do |format|
      format.json { render :json => @count_session.to_json(:methods => [:segment_id, :duration_minutes]) }
    end
  end
  
  def create
    @count_session = CountSession.new pick(params, :user_id, :project_id, :gate_id, :count_plan_id, :start, :stop, :status)
    
    respond_to do |format|
      if @count_session.save
        # create the Count's
        params[:counts].each { |count| @count_session.counts.create :at => count[:at] }

        format.json  { render :json => @count_session, :status => :created, :location => api_project_count_session_url(@count_session.project, @count_session) }
      else
        format.json  { render :json => @count_session.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @count_session = CountSession.find(params[:id])

    if counts = params[:counts]
      counts.each do |c|
        count = Count.create(:at => c[:at],
                             :count_session_id => c[:count_session_id])
      end
    end

    respond_to do |format|
      if @count_session.update_attributes(params[:count_session])
        format.json  { render :json => @count_session }
      else
        format.json  { render :json => @count_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @count_session = CountSession.find(params[:id])
    @count_session.destroy

    respond_to do |format|
      format.json { render :json => nil, :status => 200 }
    end
  end
end