class Gate < ActiveRecord::Base
  belongs_to :segment
  belongs_to :gate_group
  belongs_to :count_plan

  # there should only be one Gate with 
  # each number label in a GateGroup
  validates_uniqueness_of :label, :scope => :gate_group_id

  before_save :auto_label
  def auto_label
    # if no label is specified, we'll automatically assign the next number
    if not self.label
      if self.gate_group.gates.length > 0
        self.label = self.gate_group.gates.last.label + 1
      else
        self.label = "1"
      end
    end
  end
end