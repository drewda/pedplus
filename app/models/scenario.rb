class Scenario < ActiveRecord::Base
  belongs_to :project
  has_many :segment_in_scenarios
  has_many :segments, :through => :segment_in_scenarios
end
