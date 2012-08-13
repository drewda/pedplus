# == Schema Information
#
# Table name: scenarios
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#
# Indexes
#
#  index_scenarios_on_project_id  (project_id)
#

class Scenario < ActiveRecord::Base
  belongs_to :project
  has_many :segment_in_scenarios
  has_many :segments, :through => :segment_in_scenarios
end
