class CountPlanUser < ActiveRecord::Base
	belongs_to :count_plan
	belongs_to :user
end