class CountPlan < ActiveRecord::Base
  belongs_to :project
  has_many :gate_groups, :order => "label ASC", :dependent => :destroy
  has_many :gates
  has_many :count_sessions, :dependent => :destroy

  accepts_nested_attributes_for :gate_groups

  before_save :archive_other_count_plans
  def archive_other_count_plans
    project.count_plans.where(:is_the_current_plan => true).update_attribute :is_the_current_plan => false
  end

  def percent_completed
    totalNumber = self.count_sessions.count
    return nil if totalNumber == 0
    numberCounted = self.count_sessions.where(:status => 'completed').count
    return numberCounted / totalNumber
  end

  def end_date
    return start_date + total_weeks.weeks + 6.days
  end
end