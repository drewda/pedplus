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