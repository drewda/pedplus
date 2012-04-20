class Admin::SiteController < Admin::AdminController
  def dashboard
    @organizations = Organization.all
    @log_entries = LogEntry.order('created_at DESC').paginate(:page => params[:log_page], :per_page => 10)

    if request.post?
    	if params[:commit] == "Clear Log Entries"
    		LogEntry.delete_all
    		redirect_to admin_root_url
    	end
    end
  end
end