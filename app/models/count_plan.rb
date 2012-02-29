class CountPlan < ActiveRecord::Base
	belongs_to :project
	has_many :count_plan_users
	has_many :users, :through => :count_plan_users
	has_many :count_plan_segments
	has_many :segments, :through => :count_plan_segments

	accepts_nested_attributes_for :count_plan_users, :count_plan_segments
end