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

  def show
    @user = User.find(params[:id])

    if current_user.organization != @user.organization
      if !current_user.orgup_admin
        return render :status => 401, :json => {:success => false, :errors => ["Unauthorized."]}
      end
    end

    
    respond_to do |format|
      format.json { render :json => @user }
    end
  end

  def update
    @user = User.find(params[:id])

    if current_user != @user
      if !current_user.orgup_admin
        return render :status => 401, :json => {:success => false, :errors => ["Unauthorized."]}
      end
    end

    respond_to do |format|
      # for now we'll only allow updating the password
      if @user.update_attributes pick(params, :password, :password_confirmation)
        flash[:notice] = 'User was successfully updated.'
        format.json  { render :json => @user }
      else
        format.json  { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
end