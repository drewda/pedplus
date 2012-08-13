# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)      default(""), not null
#  phone_number           :string(255)
#  organization_id        :integer
#  organization_billing   :boolean
#  organization_manager   :boolean
#  encrypted_password     :string(128)      default(""), not null
#  invitation_token       :string(60)
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  s3sol_admin            :boolean
#
# Indexes
#
#  index_users_on_invitation_token  (invitation_token)
#  index_users_on_organization_id   (organization_id)
#

class User < ActiveRecord::Base
  belongs_to :organization
  has_many :project_members, :dependent => :destroy
  has_many :projects, :through => :project_members
  
  has_many :gate_groups
  has_many :count_sessions, :dependent => :destroy

  has_many :log_entries
  
  devise :database_authenticatable, 
         :invitable,
         :recoverable, 
         :rememberable, 
         :trackable, 
         :validatable

  accepts_nested_attributes_for :project_members, :allow_destroy => true

  validates :organization, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true
  validate :cannot_remove_own_manager_permission
  def cannot_remove_own_manager_permission
    if self.organization_manager_was == true and self.organization_manager == false
      errors.add :organization_manager, "You cannot remove your own manager permission. Please contact S3Sol for assistance."
    end
  end
  validate :cannot_remove_own_billing_permission
  def cannot_remove_own_billing_permission
    if self.organization_billing_was == true and self.organization_billing == false
      errors.add :organization_billing, "You cannot remove your own billing permission. Please contact S3Sol for assistance."
    end
  end
  validate :cannot_remove_own_s3sol_admin_permission
  def cannot_remove_own_s3sol_admin_permission
    if self.s3sol_admin_was == true and self.s3sol_admin == false
      errors.add :s3sol_admin, "You cannot remove your own S3Sol admin permission. Use the Rails console to do so."
    end
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def full_name_and_email
    "#{full_name} <#{email}>"
  end
  
  def viewable_projects
    project_members.where(:view => true).map { |pm| pm.project }
  end

  def countable_projects
    project_members.where(:count => true).map { |pm| pm.project }
  end

  def plannable_projects
    project_members.where(:plan => true).map { |pm| pm.project }
  end
  
  def mappable_projects
    project_members.where(:map => true).map { |pm| pm.project }
  end
  
  def manageable_projects
    project_members.where(:manage => true).map { |pm| pm.project }
  end
  
  attr_accessor :current_user
  def is_current_user
    return self == current_user
  end
end
