class Api::ModelJobsController < Api::ApiController
  def index
    @model_jobs = ModelJob.where(:project_id => params[:project_id])
    
    respond_to do |format|
      format.json { render :json => @model_jobs }
    end
  end

  def create
    params[:model_job].delete 'cid'

    @model_job = ModelJob.new params[:model_job]
    @model_job.project = Project.find(params[:project_id])
    
    respond_to do |format|
      if @model_job.save
        # DISABLED: Resque.enqueue(CalculateModel, @model_job.id)

        # create a log entry
        LogEntry.create :kind => 'model-job',
                        :organization => @model_job.project.organization,
                        :user => current_user,
                        :project => @model_job.project,
                        :model_job => @model_job,
                        :note => 'model started'

        format.json  { render :json => @model_job, :status => :created, :location => api_project_model_job_url(@model_job.project, @model_job) }
      else
        format.json  { render :json => @model_job.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @model_job = ModelJob.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => @model_job }
    end
  end
end