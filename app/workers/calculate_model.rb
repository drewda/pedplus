class CalculateModel
  @queue = :model_job_queue
  
  def self.perform(model_job_id)
    modelJob = ModelJob.find(model_job_id)
    modelJob.update_attribute(:started, true)    
    startTime = Time.now # keep track of seconds to run
    
    if modelJob.kind == "permeability"
      # run the python script and capture its text output
      permeabilityPath = Rails.root.join('lib','tasks','permeability.py')
      output = %x(python #{permeabilityPath.to_s} #{modelJob.project.id})
      
      # record the number of seconds elapsed
      secondsElapsed = (Time.now - startTime).to_i
      
      # record results to database
      modelJob.update_attribute(:output, output)
      modelJob.update_attribute(:seconds_to_run, secondsElapsed)
      modelJob.update_attribute(:finished, true)
      
      # tell the browser
      # so that it can refetch the results of the ModelJob
      # channel = "organization-#{modelJob.project.organization.id}"
      # message = "modelJob-complete-#{modelJob.id}"
      # Juggernaut.publish channel, message
      
      # for now we'll just have the browser poll
      
    elsif modelJob.kind == "proximity"
      # TODO
    end
  end
end