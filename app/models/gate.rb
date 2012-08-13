# == Schema Information
#
# Table name: gates
#
#  id                      :integer          not null, primary key
#  segment_id              :integer
#  gate_group_id           :integer
#  count_plan_id           :integer
#  counting_days_remaining :integer
#  label                   :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_gates_on_count_plan_id  (count_plan_id)
#  index_gates_on_gate_group_id  (gate_group_id)
#  index_gates_on_segment_id     (segment_id)
#

class Gate < ActiveRecord::Base
  belongs_to :segment
  belongs_to :gate_group
  belongs_to :count_plan
  has_many :count_sessions, :dependent => :destroy

  # there should only be one Gate with 
  # each number label in a GateGroup
  validates_uniqueness_of :label, :scope => :gate_group_id

  def full_label
  	"#{gate_group.label}-#{label}"
  end
end
