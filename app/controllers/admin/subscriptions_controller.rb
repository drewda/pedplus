class Admin::SubscriptionsController < Admin::AdminController
  def index
    @subscriptions = Subscription.all
  end
  
  def new
    @subscription = Subscription.new
  end
  
  def show
    @subscription = Subscription.find(params[:id])
  end
  
  def edit
    @subscription = Subscription.find(params[:id])
  end
  
  def create
    @subscription = Subscription.new(params[:subscription])

    respond_to do |format|
      if @subscription.save
        flash[:success] = "<strong>#{@subscription.name}</strong> subscription created."
        format.html { redirect_to(admin_subscription_url(@subscription)) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @subscription = Subscription.find(params[:id])

    respond_to do |format|
      if @subscription.update_attributes(params[:subscription])
        flash[:success] = "<strong>#{@subscription.name}</strong> subscription updated."
        format.html { redirect_to(admin_subscription_url(@subscription)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

    respond_to do |format|
      flash[:success] = "<strong>#{@subscription.name}</strong> subscription deleted."
      format.html { redirect_to(admin_subscriptions_url) }
    end
  end
end