# == Schema Information
#
# Table name: segment_in_scenarios
#
#  id          :integer          not null, primary key
#  scenario_id :integer
#  segment_id  :integer
#  status      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_segment_in_scenarios_on_scenario_id  (scenario_id)
#  index_segment_in_scenarios_on_segment_id   (segment_id)
#

class SegmentInScenario < ActiveRecord::Base
  belongs_to :segment
  belongs_to :scenario
end
