class CouponCode < ActiveRecord::Base
	validates_presence_of :code, :max_total, :max_account, :validity, :affects, :amount, :amount_unit
	validates_inclusion_of :affects, :in => [ "account", "subscriptions" ], :message => "is not valid"
	validates_inclusion_of :amount_unit, :in => [ "points", "percentage" ], :message => "is not valid"
	validates_uniqueness_of :code
end

