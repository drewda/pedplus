class GateGroup < ActiveRecord::Base
  belongs_to :count_plan
  belongs_to :user_id
  has_many :gates, :order => "label ASC"

  accepts_nested_attributes_for :gates

  attribute_choices :status, 
                    [
                      ['proposed', 'Proposed'],
                      ['accepted', 'Accepted'],
                      ['declined', 'Declined']
                    ],
                    :validate => true

  # there should only be one GateGroup with 
  # each letter label in a count plan
  validates_uniqueness_of :label, :scope => :count_plan_id
  # and only one of each color
  validates_uniqueness_of :color, :scope => :count_plan_id

  before_save :auto_label
  def auto_label
    # If no label is specified, we'll automatically assign the next letter.
    # When the last label was Z, the next label will be AA.
    if not self.label
      if self.count_plan.gate_groups.length > 0
        self.label = self.count_plan.gate_groups.last.label.succ
      else
        self.label = "A"
      end
    end
  end
end