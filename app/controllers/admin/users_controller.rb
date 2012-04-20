class Admin::UsersController < Admin::AdminController
  def index
    @users = Organization.find(params[:organization_id]).users
  end
  
  def new
    @user = User.new
    @user.organization = Organization.find(params[:organization_id])
  end
  
  def show
    @user = Organization.find(params[:organization_id]).users.find(params[:id])
  end
  
  def edit
    @user = Organization.find(params[:organization_id]).users.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:success] = "User account created for <strong>#{@user.full_name}</strong>."
        format.html { redirect_to(admin_organization_user_url(@user.organization, @user)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:success] = "User account updated for <strong>#{@user.full_name}</strong>."
        format.html { redirect_to(admin_organization_user_url(@user.organization, @user)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user == current_user
      flash[:error] = "You cannot delete your own user account."
    else
      if @user.destroy
        flash[:success] = "User account deleted for <strong>#{@user.full_name}</strong>."
      end
    end

    respond_to do |format|
      format.html { redirect_to(admin_organization_url(@user.organization)) }
    end
  end
end