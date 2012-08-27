class SmartphoneController < ApplicationController
  
  before_filter :authenticate_user!
  
  def dashboard
    # channel = "organization-#{current_user.organization.id}"
    # Juggernaut.publish channel, "notice:-:#{current_user.full_name} signed in."

    @projects = current_user.viewable_projects
    @users = current_user.organization.users

    # kludge!
    @projects.each do |p|
      p.current_user = current_user
    end
    @users.each do |u|
      u.current_user = current_user
    end
  end
end