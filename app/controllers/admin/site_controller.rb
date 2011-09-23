class Admin::SiteController < Admin::AdminController
  def dashboard
    @organizations = Organization.all
    @users = User.all
    @projects = Project.all
    @subscriptions = Subscription.all
  end
end