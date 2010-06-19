class SubscriptionController < ApplicationController
	skip_filter :require_login, :only => [ :bm ]
	
  def bm
  	@service = Service.find_by_name('Beyond Monitoring')
  	@bm_plans = Plan.find(:all, :conditions => { :service_id => @service[:id] } )
  	if params[:plan]
  		@plan = Plan.find(:first, :conditions => { :service_id => @service[:id], :name => params[:plan] })
	end
  	
  	params[:bm_subscription] = session[:bm_subscription] if params[:bm_subscription] == nil
  	params[:server] = session[:server] if params[:server] == nil
  	
  	@server = Server.new(params[:server])
	@server.account_id = 0
	
	if @plan
		@bm_subscription = BmSubscription.new
		begin
			@bm_subscription.service_provider = params[:bm_subscription][:service_provider]
			@bm_subscription.bm_included_cats = params[:bm_subscription][:bm_included_cats].to_i || @plan.bm_data.included_cats
			raise if params[:bm_subscription][:bm_included_cats] == nil
		rescue
			@bm_subscription.bm_included_cats = @plan.bm_data.included_cats
		end
		
		@bm_subscription.bm_additional_cat_price = @plan.bm_data.additional_cat_price_cents
		@bm_subscription.subscription = Subscription.new
		@bm_subscription.subscription.plan = @plan
		@bm_subscription.subscription.setup_fee_cents = @plan.setup_fee_cents
		@bm_subscription.subscription.monthly_fee_cents = @plan.monthly_fee_cents + (@bm_subscription.bm_included_cats - @plan.bm_data.included_cats) * @bm_subscription.bm_additional_cat_price
		@bm_subscription.subscription_id = 0
	end
		
	if request.post? and params[:dont_save] != 'true'
		@server.valid?
		@bm_subscription.valid?

		if @server.valid? and @bm_subscription.valid?
			session[:server] = params[:server]
			session[:bm_subscription] = params[:bm_subscription]
			session[:plan] = @bm_subscription.subscription.plan.id

			redirect_to :action => 'add'
		end
	end
	
	render :layout => false if params[:ajax] == 'true'
  end

	def add
		@service = Service.find_by_name('Beyond Monitoring')
		@plan    = Plan.find_by_id(session[:plan])

		@bm_subscription = BmSubscription.new
		begin
			@bm_subscription.service_provider = session[:bm_subscription][:service_provider]
			@bm_subscription.bm_included_cats = session[:bm_subscription][:bm_included_cats].to_i || @plan.bm_data.included_cats
		rescue
			@bm_subscription.bm_included_cats = @plan.bm_data.included_cats
		end
		
		@bm_subscription.bm_additional_cat_price = @plan.bm_data.additional_cat_price_cents
		@bm_subscription.bm_guaranteed_response_time = @plan.bm_data.guaranteed_response_time
		@bm_subscription.subscription = Subscription.new
		@bm_subscription.subscription.plan = @plan
		@bm_subscription.subscription.setup_fee_cents = @plan.setup_fee_cents
		@bm_subscription.subscription.monthly_fee_cents = @plan.monthly_fee_cents + (@bm_subscription.bm_included_cats - @plan.bm_data.included_cats) * @bm_subscription.bm_additional_cat_price
		@server = Server.new(session[:server])
		@server.account = @account
		@server.created_by = @user
		@server.user_id = @user.id
		@bm_subscription.subscription_id = 0

		if ! @server or ! @bm_subscription or ! @server.valid? or ! @bm_subscription.valid?
			render :action => 'bm' and return
		end
		
		if ! @server.save
			render :action => 'bm' and return
		end
		
		@bm_subscription.subscription.server = @server
		@bm_subscription.subscription.save
		@bm_subscription.subscription_id = @bm_subscription.subscription.id
		
		if ! @bm_subscription.save
			@server.destroy
			@bm_subscription.subscription.destroy
			render :action => 'bm', :index => @plan.name and return
		end

		session[:server] = nil
		session[:bm_subscription] = nil

		flash[:notice] = "Subscription successfully created."
		redirect_to :controller => 'billing'
	end
end
