class Manage::UsersController < Manage::ManageController
  def index
    @organization = current_user.organization
    @users = @organization.users
  end
  
  def new
    # limit the number of users that can be created
    if current_user.organization.users.length < current_user.organization.max_number_of_users
      @user = User.new
    else
      flash[:success] = "Your organization has no remaining user credits. Please contact S3Sol to upgrade your account."
      redirect_to manage_root_url
    end
  end
  
  def show
    @user = User.find(params[:id])
    # do not show users outside of current user's organization
    if @user.organization != current_user.organization
      redirect_to manage_root_url
    end
  end
  
  def edit
    @user = User.find(params[:id])
    # do not allow editing for users outside of current user's organization
    if @user.organization != current_user.organization
      redirect_to manage_root_url
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.organization = current_user.organization

    respond_to do |format|
      if @user.save
        flash[:success] = "User account created for <strong>#{@user.full_name}</strong>."
        format.html { redirect_to(manage_user_url(@user)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @user = User.find(params[:id])
    # do not allow updating for users outside of current user's organization
    if @user.organization != current_user.organization
      redirect_to manage_root_url
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:success] = "User account updated for <strong>#{@user.full_name}</strong>."
        format.html { redirect_to(manage_user_url(@user)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    # do not allowing deleting users outside of current user's organization
    if @user.organization != current_user.organization
      redirect_to manage_root_url
    end
    @user.destroy

    respond_to do |format|
      flash[:success] = "User account deleted for <strong>#{@user.full_name}</strong>."
      format.html { redirect_to(manage_users_url) }
    end
  end
end