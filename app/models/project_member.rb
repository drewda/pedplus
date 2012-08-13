# == Schema Information
#
# Table name: project_members
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  project_id :integer
#  view       :boolean
#  manage     :boolean
#  created_at :datetime
#  updated_at :datetime
#  count      :boolean          default(FALSE)
#  map        :boolean
#  plan       :boolean
#
# Indexes
#
#  index_project_members_on_project_id  (project_id)
#  index_project_members_on_user_id     (user_id)
#

class ProjectMember < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
end
