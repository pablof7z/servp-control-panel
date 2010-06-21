class BillingController < ApplicationController
	def index
		@billing = Billing.new
		@pending_subs = @account.pending_subscriptions
		@pending_subs_prices_monthly_fee, @pending_subs_prices_setup_fees = @account.pending_subscriptions_prices
		@active_subs = @account.active_subscriptions
		
		@pending_subs.each do |subscription|
			subscription.link_coupon
		end
	end
	
	def coupon
		if ! request.post?
			@applied_coupon = AppliedCoupon.new
		else
			@applied_coupon = AppliedCoupon.new
			@applied_coupon.account = @account
			if @applied_coupon.set_code(params[:code]) != true
				flash[:warning] = @applied_coupon.errors.full_messages[0]
				@applied_coupon.errors.clear
			elsif @applied_coupon.save
				flash[:notice] = "Coupon #{@applied_coupon.coupon_code.code} applied - #{@applied_coupon.coupon_code.description}."
			end
		end
		
		if params[:ajax] = 'true'
			redirect_to :controller => 'billing', :action => 'index', :id => 'coupon' and return
		end
	end

	def remove_item
		subscription = Subscription.find(params[:id])
	
		if subscription == nil or
		   subscription.server.allowed_for?(@user, :billing) == false
			flash[:warning] = 'Unable to remove subscription'
		else
			subscription.destroy
			flash[:notice] = 'Subscription removed'
		end

		redirect_to :action => 'index' and return
	end

	def pending_subs
		# Create billing object
		@billing = Billing.new
		@billing.account = Account.find_by_mask(params[:billing][:account_id])
		@billing.source = "paypal"
		ps = @account.pending_subscriptions

		# Validate the account
		if @billing.account.allowed_for(@user, :billing) == false
			flash[:warning] = 'Unable to find account'
			redirect_to :action => 'index' and return
		end

		render :action => 'index' and return if ! @billing.save
		
		ps.each {|s| s.billing = @billing; s.save}

		#if @billing.source == 'paypal'
		if true
			bp = BillingPaypal.new
			bp.billing = @billing
			amount, setup_fee = @billing.account.pending_subscriptions_prices
			bp.amount = amount
			bp.amount_currency = DEFAULT_CURRENCY
			bp.save

			days_to_end_of_month = (Date.first_day_of_next_month - Date.today).to_i
			price_to_end_of_month = (bp.amount.to_s.to_f/Date.days_in_month) * days_to_end_of_month + setup_fee.to_s.to_f
			price_to_end_of_month = price_to_end_of_month.round(2)

			redirect_to "https://#{PAYPAL_URL}/cgi-bin/webscr?cmd=_xclick-subscriptions&business=#{PAYPAL_USER}&lc=US&item_name=Server+Protectors+-+Subscription:+%23#{@billing.mask}&item_number=#{@billing.mask}&no_note=1&no_shipping=1&a1=#{price_to_end_of_month}&p1=#{days_to_end_of_month}&t1=D&a3=#{bp.amount}&return=https://serverprotectors.com&cancel_return=https://serverprotectors.com&currency_code=#{DEFAULT_CURRENCY}&src=1&p3=1&t3=M&sra=1&bn=PP-SubscriptionsBF%3abtn_subscribeCC_LG.gif%3aNonHosted"
		else
			logger.error "Unknown billing method #{@billing.source}"
			flash[:error] = "Unknown billing method selected."
			@billing.destroy
			render :action => 'index' and return
		end
	end
end
