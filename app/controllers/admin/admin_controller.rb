class Admin::AdminController < ApplicationController
  before_filter :authenticate_user!

  before_filter do 
    redirect_to :new_user_session unless current_user && current_user.s3sol_admin?
  end
end