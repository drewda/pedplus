class Project < ActiveRecord::Base
  belongs_to :organization
  has_many :project_members
  has_many :users, :through => :project_members
  
  has_many :segments
  has_many :geo_points
  has_many :geo_point_on_segments
  has_many :count_sessions
  has_many :scenarios
  
  accepts_nested_attributes_for :project_members, :allow_destroy => true
  
  def geographic_center
    geographic_center = Geocoder::Calculations.geographic_center geo_points.map { |gp| [gp.latitude.to_f, gp.longitude.to_f] }
    if !geographic_center[0].nan?
      return {
        latitude: geographic_center[0],
        longitude: geographic_center[1]
      }
    else
      return nil
    end
  end
end