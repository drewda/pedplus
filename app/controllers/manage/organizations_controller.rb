class Manage::OrganizationsController < Manage::ManageController
  def show
    @organization = Organization.find(params[:id])
    # do not show an organization other than the current user's own
    if @organization != current_user.organization
      redirect_to manage_root_url
    end
  end
  
  def edit
    @organization = Organization.find(params[:id])
    # do not allow editing of an organization other than the current user's own
    if @organization != current_user.organization
      redirect_to manage_root_url
    end
  end
  
  def update
    @organization = Organization.find(params[:id])
    # do not allow updating of an organization other than the current user's own
    if @organization != current_user.organization
      redirect_to manage_root_url
    end

    respond_to do |format|
      # make sure there is at least one user with manager and billing permissions for the organization
      if not params[:organization][:users_attributes].any? {|k, v| v[:organization_billing] == '1'}
        flash[:error] = "Your organization must have at least one user with billing permissions."
        format.html { render :action => "edit" }
      elsif not params[:organization][:users_attributes].any? {|k, v| v[:organization_manager] == '1'}
        flash[:error] = "Your organization must have at least one user with manager permissions."
        format.html { render :action => "edit" }
      elsif @organization.update_attributes(params[:organization])
        flash[:success] = "Organization record updated for <strong>#{@organization.name}</strong>."
        format.html { redirect_to manage_root_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end