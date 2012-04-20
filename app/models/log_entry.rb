class LogEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
  belongs_to :project
  belongs_to :model_job
  belongs_to :count_plan
  belongs_to :count_session

  attribute_choices :kind, 
                    [
                      ['user', 'User'], 
                      ['organization', 'organization'],
                      ['project', 'Project'],
                      ['model-job', 'Model Job'],
                      ['count-plan', 'Count Plan'],
                      ['cout-session', 'Count Session']
                    ],
                    :validate => true
end