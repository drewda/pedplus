class Organization < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  
  accepts_nested_attributes_for :users

  attribute_choices :kind, 
                    [
                      ['free-trial', 'Free Trial'], 
                      ['professional', 'Professional'],
                      ['academic-institution', 'Academic Institution'],
                      ['student-pro', 'Student Pro']
                    ],
                    :validate => true

  validates :name, :presence => true, :uniqueness => true
  validates :country, :presence => true
  validates :time_zone, :presence => true
  validates :max_number_of_users, :presence => true
  validates :max_number_of_projects, :presence => true
  validates :default_counting_days_per_gate, :presence => true
  validates :default_max_number_of_gates_per_project, :presence => true
  validates :subscription_active_until, :presence => true

  def software_package
  	if self.owns_pedplus
  		return "PedPlus"
  	elsif self.owns_pedcount
  		return "PedCount"
  	end
  end

  def software_packages
    if self.owns_pedplus
      return Project.kind_choices
    else
      return Project.kind_choices.delete_if { |k| k[1] == 'pedplus' }
    end
  end

  def user_credits_available
    return self.max_number_of_users - self.users.length
  end

  def project_credits_available
    return self.max_number_of_projects - self.projects.length
  end

  def manager_users
    self.users.where(:organization_manager => true)
  end

  def billing_users
    self.users.where(:organization_billing => true)
  end
end