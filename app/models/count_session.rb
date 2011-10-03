class CountSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :segment
  has_many :counts, :order => "at DESC"
  
  accepts_nested_attributes_for :counts
  
  def total_count
    counts.length
  end
end
