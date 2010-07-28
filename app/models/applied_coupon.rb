class AppliedCoupon < ActiveRecord::Base
  belongs_to :coupon_code
  belongs_to :account
  has_many :applied_coupon_subscription
  has_many :subscriptions, :through => :applied_coupon_subscription

  validates_presence_of :coupon_code_id, :account_id, :start, :finish

  def set_code(code)
    coupon = CouponCode.find_by_code(code)

    raise "No account used" if self.account == nil

    if coupon == nil and code != nil
      errors.add_to_base "There is no coupon with that code."
      return
    end

    if coupon != nil
      errors.add_to_base "That coupon is not active." and return if coupon.not_before > DateTime.now
      errors.add_to_base "That coupon is not active." and return if coupon.not_after != nil and coupon.not_after < DateTime.now
      errors.add_to_base "That coupon has been completed." and return if coupon.max_total <= coupon.applied_coupons.size
      errors.add_to_base "That coupon has been completely used by this account." and return if coupon.max_account <= (l = 0 and coupon.applied_coupons.each { |c| l += 1 if c.account == account } and l)
    end

    self.coupon_code = coupon

    return true
  end

  def before_validation_on_create
    self.start ||= DateTime.now
    self.finish ||= start + coupon_code.validity.days
  end
end
