class CountSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :gate
  belongs_to :count_plan
  has_many :counts, :order => "at DESC", :dependent => :delete_all
  
  accepts_nested_attributes_for :counts

  attribute_choices :status, 
                    [
                      ['counting', 'Counting'], 
                      ['completed', 'Completed']
                    ],
                    :validate => true

  def segment_id
    return gate.segment_id
  end

  def duration_minutes
    ((self.stop - self.start) / 60).round(1)
  end
end