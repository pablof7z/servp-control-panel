class AppliedCoupon < ActiveRecord::Base
	belongs_to :coupon, :class_name => 'CouponCode'
	belongs_to :account
	
	validates_presence_of :coupon_id, :account_id, :start, :finish
end
