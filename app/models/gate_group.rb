class GateGroup < ActiveRecord::Base
  belongs_to :count_plan
  belongs_to :user
  has_many :gates, :order => "label ASC", :dependent => :destroy

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
end