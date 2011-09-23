class Subscription < ActiveRecord::Base
  has_many :organizations
  
  validates :name, :presence => true
  validates :max_users, :presence => true, :numericality => true
  validates :max_projects, :presence => true, :numericality => true
end