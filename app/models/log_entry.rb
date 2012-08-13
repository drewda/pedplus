# == Schema Information
#
# Table name: log_entries
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  organization_id  :integer
#  project_id       :integer
#  model_job_id     :integer
#  count_plan_id    :integer
#  count_session_id :integer
#  kind             :string(255)
#  note             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

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
