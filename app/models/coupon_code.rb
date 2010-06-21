class CouponCode < ActiveRecord::Base
	has_many :applied_coupons
	
	validates_presence_of :code, :max_total, :max_account, :validity, :affects, :amount, :amount_unit
	validates_inclusion_of :affects, :in => [ "account", "subscriptions" ], :message => "is not valid"
	validates_inclusion_of :amount_unit, :in => [ "points", "percentage" ], :message => "is not valid"
	validates_uniqueness_of :code
	
	def apply_to(i)
		case self.amount_unit
			when 'points'
				[0, i - self.amount].max
			when 'percentage'
				logger.error "#{i} * ((100 - #{self.amount})) / 100 = #{i * ((100 - self.amount)) / 100}"
				i * ((100 - self.amount)) / 100
			else
				raise "amount unit set to #{self.amount_unit}"
		end
	end
end

