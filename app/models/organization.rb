# == Schema Information
#
# Table name: organizations
#
#  id                                      :integer          not null, primary key
#  name                                    :string(255)
#  slug                                    :string(255)
#  url                                     :string(255)
#  address                                 :string(255)
#  city                                    :string(255)
#  state                                   :string(255)
#  country                                 :string(255)
#  postal_code                             :string(255)
#  created_at                              :datetime
#  updated_at                              :datetime
#  owns_pedcount                           :boolean          default(TRUE)
#  owns_pedplus                            :boolean          default(FALSE)
#  max_number_of_users                     :integer          default(1)
#  max_number_of_projects                  :integer          default(1)
#  time_zone                               :string(255)      default("Pacific Time (US & Canada)")
#  kind                                    :string(255)
#  default_max_number_of_gates_per_project :integer
#  subscription_active_until               :date
#  default_counting_days_per_gate          :integer
#  extra_counting_day_credits_available    :integer          default(0)
#  allowed_to_export_projects              :boolean          default(FALSE)
#

class Organization < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  has_many :projects, :dependent => :destroy

  has_many :log_entries
  
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
  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true
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

  def is_subscription_still_active?
    subscription_active_until > Date.today
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
