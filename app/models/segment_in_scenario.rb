class SegmentInScenario < ActiveRecord::Base
  belongs_to :segment
  belongs_to :scenario
end
