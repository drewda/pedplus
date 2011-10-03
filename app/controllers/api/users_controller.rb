class Api::UsersController < Api::ApiController
  def index
    @users = current_user.organization.users
    
    # kludge!
    @users.each do |u|
      u.current_user = current_user
    end
    
    respond_to do |format|
      format.json { render :json => @users.to_json(:methods => [:is_current_user]) }
    end
  end
end