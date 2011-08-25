class CountSession < ActiveRecord::Base
  belongs_to :segment
  has_many :counts, :order => "at DESC"
end
