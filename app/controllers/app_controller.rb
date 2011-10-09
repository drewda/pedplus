class AppController < ApplicationController
  
  before_filter :authenticate_user!
  
  def dashboard
    # channel = "organization-#{current_user.organization.id}"
    # Juggernaut.publish channel, "notice:-:#{current_user.full_name} signed in."
  end
end