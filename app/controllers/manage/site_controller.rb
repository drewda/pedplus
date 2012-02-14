class Manage::SiteController < Manage::ManageController
  def dashboard
    @organization = current_user.organization
    @users = @organization.users
    @projects = @organization.projects
  end
end