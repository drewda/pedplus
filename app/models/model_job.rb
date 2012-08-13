# == Schema Information
#
# Table name: model_jobs
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  kind            :string(255)
#  parameters      :text
#  output          :text
#  started         :boolean
#  finished        :boolean
#  picked_up       :boolean
#  seconds_to_run  :integer
#  created_at      :datetime
#  updated_at      :datetime
#  project_version :integer          default(1)
#
# Indexes
#
#  index_model_jobs_on_project_id  (project_id)
#

class ModelJob < ActiveRecord::Base
  belongs_to :project

  has_many :log_entries

  before_save :delete_old_model_jobs
  def delete_old_model_jobs
    # delete all the other old model jobs that have been run
    # for this project and are the same kind of model as this
    # new one
    project.model_jobs.each do |model_job|
      if model_job.kind == self.kind
        model_job.destroy unless model_job == self
      end
    end
  end
end
