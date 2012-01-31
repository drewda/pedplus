class Project < ActiveRecord::Base
  belongs_to :organization
  has_many :project_members
  has_many :users, :through => :project_members
  
  has_many :segments
  has_many :geo_points
  has_many :geo_point_on_segments
  has_many :count_sessions
  has_many :scenarios
  
  has_many :model_jobs
  
  accepts_nested_attributes_for :project_members, :allow_destroy => true

  attribute_choices :kind, 
                    [['pedcount', 'PedCount'], ['pedplus', 'PedPlus']],
                    :validate => true
  
  def cache_bounding_box
    southwestLatitude = -Float::INFINITY
    southwestLongitude = Float::INFINITY
    northeastLatitude = Float::INFINITY
    northeastLongitude = -Float::INFINITY
    
    geo_points.each do |gp|
      latitude = gp.latitude.to_f
      longitude = gp.longitude.to_f
      if longitude < southwestLongitude
        southwestLongitude = longitude
      end
      if longitude > northeastLongitude
        northeastLongitude = longitude
      end
      if latitude < northeastLatitude
        northeastLatitude = latitude 
      end
      if latitude > southwestLatitude
        southwestLatitude = latitude
      end 
    end
    
    self.update_attributes(
      :southwest_latitude => southwestLatitude,
      :southwest_longitude => southwestLongitude,
      :northeast_latitude => northeastLatitude,
      :northeast_longitude => northeastLongitude
    )
  end
end