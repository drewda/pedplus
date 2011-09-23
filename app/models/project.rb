class Project < ActiveRecord::Base
  belongs_to :organization
  has_many :project_members
  has_many :users, :through => :project_members
  
  has_many :segments
  has_many :geo_points
  has_many :count_sessions
  has_many :scenarios
  
  accepts_nested_attributes_for :project_members, :allow_destroy => true
end