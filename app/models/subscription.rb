class Subscription < ActiveRecord::Base
	belongs_to :server
	belongs_to :plan
	belongs_to :billing
#	has_many :invoice_items
#	has_many :invoices, :through => 'invoice_items'
	has_many :subscription_periods
	has_one :bm_subscription, :dependent => :destroy, :class_name => 'BmSubscription'
#	has_one :service, :through => :plan
	has_many :applied_coupon_subscriptions
	
	composed_of :monthly_fee, :class_name => 'Money', :mapping => [%w(monthly_fee_cents cents), %w(setup_fee_currency currency)]
	composed_of :setup_fee, :class_name => 'Money', :mapping => [%w(setup_fee_cents cents), %w(monthly_fee_currency currency)]

	def billing?
		!!billing and (billing.source == 'paypal' ? (billing.paypal and !billing.paypal.subscription.blank?) : true)
	end

	def plan_editable_by_user?
		enabled == false
	end
	
	def validate
		other_scs = Subscription.find(:all, :conditions => { :server_id => self.server_id })
		
		other_scs.each do |sc|
			next if self[:id] == sc[:id]
			if sc.plan.service_id == self.plan.service_id
				errors.add_to_base("A subsciption to the service #{self.plan.service.name} already exists on this server")
			end
		end
	end
	
	def to_label
		"#{plan.service.name}: #{server.name} - #{plan.name}"
	end
	
	def link_coupon
		server.account.applied_coupons.each do |applied_coupon|
# TODO		
#			if applied_coupon.coupon_code.affects == 'account'
#			elsif applied_coupon.coupon_code.affects == 'subscriptions'
#			end
			next if applied_coupon.start > DateTime.now or applied_coupon.finish < DateTime.now
			
			# Check if this subscription already has this coupon
			sub = AppliedCouponSubscription.find(:all, :conditions => { :subscription_id => self.id, :applied_coupon_id => applied_coupon.id })
			next if sub.size > 0
			
			sub = AppliedCouponSubscription.new
			sub.subscription = self
			sub.applied_coupon = applied_coupon
			sub.save
		end
	end
end
