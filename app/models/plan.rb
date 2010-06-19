class Plan < ActiveRecord::Base
	belongs_to :service
#	has_many :subscriptions
#	has_many :servers, :through => :subscriptions
	has_one :bm_data, :class_name => 'BmPlan'
	
	composed_of :monthly_fee, :class_name => 'Money', :mapping => [%w(monthly_fee_cents cents), %w(fees_currency currency)]
	composed_of :setup_fee, :class_name => 'Money', :mapping => [%w(setup_fee_cents cents), %w(fees_currency currency)]
	
	validates_presence_of :name, :fees_currency
	validates_numericality_of :monthly_fee_cents, :setup_fee_cents
end
