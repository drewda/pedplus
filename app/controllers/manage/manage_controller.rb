class Manage::ManageController < ApplicationController
  before_filter :authenticate_user!

  before_filter do 
    redirect_to :new_user_session unless current_user && current_user.organization_manager?
  end
end