# == Schema Information
#
# Table name: count_plans
#
#  id                             :integer          not null, primary key
#  project_id                     :integer
#  start_date                     :date
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  is_the_current_plan            :boolean
#  count_session_duration_seconds :integer
#  total_weeks                    :integer
#
# Indexes
#
#  index_count_plans_on_project_id  (project_id)
#

class CountPlan < ActiveRecord::Base
  belongs_to :project
  has_many :gate_groups, :order => "label ASC", :dependent => :destroy
  has_many :gates, :dependent => :destroy
  has_many :count_sessions, :dependent => :destroy

  has_many :log_entries

  accepts_nested_attributes_for :gate_groups

  before_save :archive_other_count_plans
  def archive_other_count_plans
    project.count_plans.where("is_the_current_plan = true AND id != ?", self.id).update_all :is_the_current_plan => false
  end

  def percent_completed
    totalNumber = self.count_sessions.count
    return 0 if totalNumber == 0
    numberCounted = self.count_sessions.where(:status => 'completed').count
    return numberCounted / totalNumber
  end

  def end_date
    start_date + total_weeks.weeks + 6.days if start_date
  end
end
