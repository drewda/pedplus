class SmartphoneController < ApplicationController
  
  before_filter :authenticate_user!
  
  def dashboard
    # channel = "organization-#{current_user.organization.id}"
    # Juggernaut.publish channel, "notice:-:#{current_user.full_name} signed in."

    @projects = current_user.viewable_projects

    # kludge!
    @projects.each do |p|
      p.current_user = current_user
    end
  end
end