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

    # Backbone shouldn't be sending all of this, 
    # but for now it is, so we want to ignore 
    # these extra attributes, which will never be 
    # updated from the browser-side
    ['cid', 'created_at', 'current_sign_in_at', 'current_sign_in_ip', 'encrypted_password', 'id', 'invitation_accepted_at', 
     'invitation_limit', 'invitation_sent_at', 'invitation_token', 'invited_by_id', 'invited_by_type', 'is_current_user',
     'last_sign_in_at', 'last_sign_in_ip', 'remember_created_at', 'reset_password_sent_at', 'reset_password_token',
     'sign_in_count', 'updated_at'].each do |a|
      params[:user].delete(a)
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.json  { render :json => @user }
      else
        format.json  { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
end