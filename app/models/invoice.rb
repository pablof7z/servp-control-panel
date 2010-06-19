class Invoice < ActiveRecord::Base
	belongs_to :account
	belongs_to :created_by, :class_name => 'User'
	has_many :invoice_items
	has_many :payments

	composed_of :subtotal, :class_name => 'Money', :mapping => [%w(subtotal_cents cents), %w(currency currency)]
	composed_of :total, :class_name => 'Money', :mapping => [%w(total_cents cents), %w(currency currency)]
	validates_presence_of :subtotal_cents, :total_cents, :created_by_id,
                          :recipient, :from, :date, :description, :currency, :exchange_rate
	validates_uniqueness_of :mask
	
	def past_due_date?
		return true if due_date != nil and Time.now > due_date
		false
	end
	
	def paid?
		self.paid != nil
	end

	def before_validation_on_create; create_mask end

	private

	def create_mask
		a = ("0".."9").to_a
		while true
			s = ""
			1.upto((7..9).to_a[rand(3)]) { |i| s << a[rand(a.size-1)] }
			break if Account.find_by_mask(s) == nil
		end
		self.mask = s
	end
end
