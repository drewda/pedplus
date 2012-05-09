class Admin::OrganizationsController < Admin::AdminController
  def index
    @organizations = Organization.all
  end
  
  def new
    @organization = Organization.new
  end
  
  def show
    @organization = Organization.find(params[:id])
  end
  
  def edit
    @organization = Organization.find(params[:id])
  end
  
  def create
    @organization = Organization.new(params[:organization])

    respond_to do |format|
      if @organization.save
        flash[:success] = "Organization record created for <strong>#{@organization.name}</strong>."
        flash[:info] = "Please add an initial user for the organization."
        format.html { redirect_to(new_admin_organization_user_url(@organization)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @organization = Organization.find(params[:id])

    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        flash[:success] = "Organization record updated for <strong>#{@organization.name}</strong>."
        format.html { redirect_to(admin_organization_url(@organization)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy

    respond_to do |format|
      flash[:success] = "Organization record deleted for <strong>#{@organization.name}</strong>."
      format.html { redirect_to(admin_organizations_url) }
    end
  end
end