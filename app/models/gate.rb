class Gate < ActiveRecord::Base
  belongs_to :segment
  belongs_to :gate_group
  belongs_to :count_plan

  # there should only be one Gate with 
  # each number label in a GateGroup
  validates_uniqueness_of :label, :scope => :gate_group_id
end