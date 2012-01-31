class Manage::ManageController < ApplicationController
  before_filter :authenticate_user!
  
  def dashboard

  end
end