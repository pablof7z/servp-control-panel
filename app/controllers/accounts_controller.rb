class AccountsController < ApplicationController
	before_filter :load_account, :except => [ :new, :create, :switch ]

  def new
  	@create_account = Account.new
  end

  def create
  	@create_account = Account.new(params[:account])
	@create_account.created_by = @user
	if @create_account.save
		flash[:notice] = "Account was created successfully."
		session[:account] = @create_account.mask
		redirect_to root_path
	else
		render :action => 'new'
	end
  end

  def profile
  end

  def switch
  	@account = Account.find_by_mask(params[:id])
	@account.allowed_for current_user
	session[:account] = @account.mask
	redirect_to session[:switch_url] || root_path
	session[:switch_url] = nil
	flash[:notice] = "You have switched accounts, you are now using account #{@account.name}."
	rescue
		flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
		redirect_to root_path
  end

  def add_user
  	if ! @account.allowed_for? current_user, :users
		flash[:warning] = "You don't have granted permissions to manage users on the account."
		redirect_to root_path
	end

	if request.post?
		user = User.find_by_username(params[:username])
		if user == nil
			flash[:warning] = "Unable to find username #{params[:username]}."
			return
		else
			permission = UserPermission.new(params[:user_permission])
			permission.user = user
			permission.set_by_user = @user
			permission.account = @account
			if permission.save
				flash[:notice] = "User #{params[:username]} added to the account."
				redirect_to :action => 'users'
			else
				flash[:warning] = "User #{params[:username]} could not be added."
				return
			end
		end
	end
  end

  def users
  end

  def remove_user
  	user = User.find_by_mask(params[:user_id])
	account = Account.find_by_mask(params[:account_id])
	account.allowed_for current_user, :users
  	permission = UserPermission.find(:first, :conditions => { :user_id => user.id, :account_id => account.id })
	permission.destroy
	redirect_to root_path
	rescue
		flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
		redirect_to root_path
  end
  
  def bc
  	@api_key = @account.md_bc_api_key
  	
  	if @account.md_bc_api_key != nil and params[:reset_api_key] != 'true'
	  	redirect_to :action => 'bc_servers', :api_key => @account.md_bc_api_key
	else
		@show_api_key = true
	end
  end
  
  def bc_servers
	bc = BinaryCanary::Session.new params[:api_key]
	@api_call = bc.list_servers
	if @api_call.has_error?
		if @api_call.errors[0].error.code == 'InvalidAPIKey'
			@errors = 'The API key is invalid'
		else
			@errors = @servers.errors[0].error.text
		end
		
		render :partial => 'bc_api', :layout => false and return
	else
		@servers = @api_call.servers
		@service = Service.find_by_name('Beyond Monitoring')
		@bm_plans = Plan.find(:all, :conditions => { :service_id => @service[:id] } ) 
		@account.md_bc_api_key = params[:api_key]
		@account.save
	end
	
	render :layout => false if request.post?
  end
  
  def bc_import
  	logger.error "here"
  	bc = BinaryCanary::Session.new params[:api_key]
	@api_call = bc.list_servers
	if @api_call.has_error?
		if @api_call.errors[0].error.code == 'InvalidAPIKey'
			@errors = 'The API key is invalid'
		else
			@errors = @servers.errors[0].error.text
		end
		
		render :partial => 'bc_api', :layout => false and return
	else
		@servers = @api_call.servers
	end
	
	@service = Service.find_by_name('Beyond Monitoring')
	@bm_plans = Plan.find(:all, :conditions => { :service_id => @service[:id] } )
	
	params.each do |k,v|
		logger.error k
		if k[0, 5] == 'plan_'
			server_id = k[5, 20]
			
			# Check if its here
			server_data = nil
			@servers.each do |data|
				logger.error "Compare #{data.server.serverid} == #{server_id}"
				if data.server.serverid == server_id
					server_data = data.server
					break
				end
			end
			
			next if server_data == nil
			
			logger.error "Got it"
			
			plan = Plan.find_by_name(v)
			
			if ! plan
				logger.error "Unable to get plan #{v}"
				next
			end
			
			# Create the server
			server = Server.new
			server.account = @account
			server.name    = server_data.servername
			server.hostname = server_data.servername
			server.created_by = @user
			
			while server_data.servername.size < 5 or
			   Server.find(:all, :conditions => { :account_id => @account.id, :name => server.name }).size > 0
				server.name = "Imported server #{rand(10000)}" 
			end
			
			if ! server.save
				flash[:warning] = "The server with ID #{server_data.serverid} could not be imported. You might want to contact us so we can help with this."
				logger.error "#{server.errors.inspect}"
				next
			end
			
			logger.error "Setting server id to #{server_data.serverid}"
			server.md_bc_server_id = server_data.serverid
			@account.md_bc_api_key = params[:api_key]
			
			included_cats = [ params["cats_#{server_data.serverid}"].to_i, plan.bm_data.included_cats ].max
			
			bm_subscription = BmSubscription.new
			bm_subscription.service_provider = 'binary canary'
			bm_subscription.bm_included_cats = included_cats
			bm_subscription.bm_additional_cat_price = plan.bm_data.additional_cat_price_cents
			bm_subscription.bm_guaranteed_response_time = plan.bm_data.guaranteed_response_time
			bm_subscription.subscription = Subscription.new
			bm_subscription.subscription.plan = plan
			bm_subscription.subscription.setup_fee_cents = plan.setup_fee_cents
			bm_subscription.subscription.monthly_fee_cents = plan.monthly_fee_cents + (included_cats - plan.bm_data.included_cats) * plan.bm_data.additional_cat_price_cents
			bm_subscription.subscription_id = 0
			bm_subscription.subscription.server = server
			if ! bm_subscription.subscription.save
				logger.error "Unable to save subscription #{bm_subscription.subscription.errors.inspect}"
			end
			bm_subscription.subscription_id = bm_subscription.subscription.id
			
			if ! bm_subscription.save
				logger.error "Unable to save subscription #{bm_subscription.errors.inspect}"
				next
			end
		end
	end
	
	redirect_to :controller => 'billing'
  end

  private

  def load_account
  	@account = Account.find_by_mask(params[:account] || session[:account] || params[:id]) || @user.accounts[0]
	@account.allowed_for current_user if @account != nil
	rescue
		flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
		redirect_to root_path
  end
end
