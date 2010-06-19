class AppliedCouponSubscription < ActiveRecord::Base
	belongs_to :applied_coupon
	belongs_to :subscription
	
	def valid?
		if (applied_coupon.start == nil or applied_coupon.start < Time.now) and
		   (applied_coupon.finish == nil or applied_coupon.finish > Time.now)
	end
end
