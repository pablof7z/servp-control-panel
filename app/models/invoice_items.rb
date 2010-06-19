class InvoiceItems < ActiveRecord::Base
	belongs_to :invoice
	belongs_to :created_by, :class_name => 'User'
	belongs_to :subscription_period

	composed_of :unit_price, :class_name => 'Money', :mapping => [%w(unit_price_cents cents), %w(unit_price_currency currency)]

	validates_presence_of :invoice_id, :description, :quantity, :unit_price_cents, :unit_price_currency, :created_by_id
end
