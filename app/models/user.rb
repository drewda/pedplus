class User < ActiveRecord::Base
  belongs_to :organization
  has_many :project_members, :dependent => :delete_all
  has_many :projects, :through => :project_members
  
  has_many :count_sessions
  
  devise :database_authenticatable, 
         :invitable,
         :recoverable, 
         :rememberable, 
         :trackable, 
         :validatable

  accepts_nested_attributes_for :project_members, :allow_destroy => true

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def full_name_and_email
    "#{full_name} <#{email}>"
  end
  
  def viewable_projects
    project_members.where(:view => true).map { |pm| pm.project }
  end
  
  def editable_projects
    project_members.where(:edit => true).map { |pm| pm.project }
  end
  
  def manageable_projects
    project_members.where(:manage => true).map { |pm| pm.project }
  end
  
end