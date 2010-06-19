class BillingPaypal < ActiveRecord::Base
	belongs_to :billing
	
	validates_presence_of :billing_id
	validates_uniqueness_of :billing_id
	
	composed_of :amount, :class_name => 'Money', :mapping => [%w(amount_cents cents), %w(amount_currency currency)]
end
