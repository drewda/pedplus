class Organization < ActiveRecord::Base
  has_many :users
  has_many :projects
  belongs_to :subscription
  
  accepts_nested_attributes_for :users
  
  validates :name, :presence => true, :uniqueness => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :country, :presence => true
end