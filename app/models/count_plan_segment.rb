class CountPlanSegment < ActiveRecord::Base
	belongs_to :count_plan
	belongs_to :segment
end