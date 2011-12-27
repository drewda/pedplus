class CountSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :segment
  has_many :counts, :order => "at DESC", :dependent => :delete_all
  
  accepts_nested_attributes_for :counts
    
  def duration
    stop - start # seconds
  end
end
