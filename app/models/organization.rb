class Organization < ActiveRecord::Base
  has_many :users
  has_many :projects
  has_many :count_session_credits
  
  accepts_nested_attributes_for :users
  
  validates :name, :presence => true, :uniqueness => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :country, :presence => true

  def software_package
  	if self.owns_pedplus
  		return "PedPlus"
  	elsif self.owns_pedcount
  		return "PedCount"
  	end
  end

  def user_credits_available
    return self.max_number_of_users - self.users.length
  end

  def project_credits_available
    return self.max_number_of_projects - self.projects.length
  end

  def count_session_credits_available
    total_count_session_credits_purchased = self.count_session_credits.sum(:count_session_credits_purchased)
    total_count_session_credits_used = self.count_session_credits.sum(:count_session_credits_used)
    return total_count_session_credits_purchased - total_count_session_credits_used
  end

  def use_a_count_session_credit
    # TODO
  end
end