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
			normal_amount = @billing.account.pending_subscriptions_prices(false)[0]
#			days_to_end_of_discount = nil

#			if amount != normal_amount
#				@billing.account.subscriptions.each do |subscription|
#					if subscription.applied_coupon_subscriptions.size > 0
#						applied_coupon = AppliedCoupon.find_by_id(subscription.applied_coupon_subscriptions[0].applied_coupon_id)
#						days_to_end_of_discount = applied_coupon.coupon_code.validity
#					end
#				end
#			end

bp.amount = normal_amount
bp.amount_currency = DEFAULT_CURRENCY
bp.save

days_to_end_of_month = (Date.first_day_of_next_month - Date.today).to_i
price_to_end_of_month = (bp.amount.to_s.to_f/Date.days_in_month) * days_to_end_of_month + setup_fee.to_s.to_f
price_to_end_of_month = price_to_end_of_month.round(2)

#			if days_to_end_of_discount != nil
#				p1 = days_to_end_of_month
#				p2 = days_to_end_of_discount
#
#				a1 = price_to_end_of_month
#				a2 = amount
#				a3 = normal_amount
#				data = "p1=#{p1}&p2=#{p2}&t1=D&t2=D&a1=#{a1}&a2=#{a2}&a3=#{a3}"
#			else
p1 = days_to_end_of_month

a1 = price_to_end_of_month
a3 = amount
data = "p1=#{p1}&t1=D&a1=#{a1}&a3=#{a3}"
#			end

redirect_to "https://#{PAYPAL_URL}/cgi-bin/webscr?cmd=_xclick-subscriptions&business=#{PAYPAL_USER}&lc=US&item_name=Server+Protectors+-+Subscription:+%23#{@billing.mask}&item_number=#{@billing.mask}&no_note=1&no_shipping=1&#{data}&return=https://serverprotectors.com&cancel_return=https://serverprotectors.com&currency_code=#{DEFAULT_CURRENCY}&src=1&p3=1&t3=M&sra=1&bn=PP-SubscriptionsBF%3abtn_subscribeCC_LG.gif%3aNonHosted"
else
	logger.error "Unknown billing method #{@billing.source}"
	flash[:error] = "Unknown billing method selected."
	@billing.destroy
	render :action => 'index' and return
end
end
end
