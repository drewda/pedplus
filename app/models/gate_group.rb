# == Schema Information
#
# Table name: gate_groups
#
#  id            :integer          not null, primary key
#  count_plan_id :integer
#  user_id       :integer
#  label         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  days          :string(255)
#  hours         :string(255)
#  status        :string(255)
#
# Indexes
#
#  index_gate_groups_on_count_plan_id  (count_plan_id)
#  index_gate_groups_on_user_id        (user_id)
#

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
