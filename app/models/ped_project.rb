class PedProject < ActiveRecord::Base
  has_many :segments
  has_many :scenarios
end
