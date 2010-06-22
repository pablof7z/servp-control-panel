class Billing < ActiveRecord::Base
	belongs_to :account
	has_many :subscriptions
	has_one :paypal, :class_name => 'BillingPaypal'
#	has_many :payments

	BILLING_SOURCES = [
		[ "PayPal", 'paypal' ]
	]

	attr_protected :mask, :source, :account_id
	validates_presence_of :account_id
	validates_inclusion_of :source, :in => BILLING_SOURCES.map {|disp, val| val}, :message => 'is not valid'
	validates_uniqueness_of :mask
	
	def self.search(q)
		p = "%#{q}%"
		result = find(:all, :conditions => [ 'mask like ?', p])
		
		BillingPaypal.find(:all, :conditions => [ 'subscription like ?', p ]).each {|m| result << m.billing }
		
		result
	end

	def before_validation_on_create; create_mask end

	private

	def create_mask
		a = ("0".."9").to_a
		while true
			s = ""
			1.upto((7..9).to_a[rand(3)]) { |i| s << a[rand(a.size-1)] }
			break if Ticket.find_by_mask(s) == nil
		end
		self.mask = s
	end
end
