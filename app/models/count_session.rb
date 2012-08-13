# == Schema Information
#
# Table name: count_sessions
#
#  id            :integer          not null, primary key
#  start         :datetime
#  stop          :datetime
#  status        :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  project_id    :integer
#  user_id       :integer
#  counts_count  :integer          default(0)
#  count_plan_id :integer
#  gate_id       :integer
#
# Indexes
#
#  index_count_sessions_on_count_plan_id  (count_plan_id)
#  index_count_sessions_on_project_id     (project_id)
#  index_count_sessions_on_user_id        (user_id)
#

class CountSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :gate
  belongs_to :count_plan
  has_many :counts, :order => "at ASC", :dependent => :delete_all

  has_many :log_entries
  
  accepts_nested_attributes_for :counts

  attribute_choices :status, 
                    [
                      ['counting', 'Counting'], 
                      ['completed', 'Completed']
                    ],
                    :validate => true

  def segment_id
    return gate.segment_id
  end

  def duration_minutes
    ((self.stop - self.start) / 60).round(1)
  end
end
