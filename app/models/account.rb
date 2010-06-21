class Account < ActiveRecord::Base
	belongs_to :created_by, :class_name => 'User'
	has_many :user_permissions, :dependent => :destroy
	has_many :users, :through => :user_permissions
	has_many :servers
	has_many :tickets
	has_many :subscriptions, :through => :servers
	has_many :account_metadatas
	has_many :applied_coupons

	validates_presence_of :name, :mask, :created_by_id

	attr_protected :mask, :created_by_id

	def active_subscriptions
		@subs = []
		subscriptions.each { |s| @subs << s if s.billing? }

		return @subs
	end

	def pending_subscriptions
		@subs = []
		subscriptions.each { |s| @subs << s if ! s.billing? }

		return @subs
	end

	def pending_subscriptions_prices
		p = pending_subscriptions

		monthly_fee = Money.new(0)
		setup_fee = Money.new(0)

		p.each do |subscription|
			monthly_fee += subscription.monthly_fee
			coupondiv = 0
			subscription.applied_coupon_subscriptions.each do |i|
				applied_coupon = i.applied_coupon
				coupondiv = (subscription.monthly_fee.to_f - (applied_coupon.coupon_code.apply_to subscription.monthly_fee.to_s.to_f).to_f)*-1
			end
			monthly_fee += Money.new(coupondiv*100)
			setup_fee += subscription.setup_fee
		end

		return monthly_fee, setup_fee
	end

	def allowed_for(user, action="*")
		if ! allowed_for? user, action
			raise "Not available for this user"
		end
	end
	
	def allowed_for?(user, action="*")
		permission = UserPermission.find(:first, :conditions => { :user_id => user.id, :account_id => self.id })
		return false if permission == nil

		case action
			when "*": return true
			when :tickets: return permission.tickets
			when :billing: return permission.billing
			when :users: return permission.users
			when :reports: return permission.reports
			when :servers: return permission.servers
			else
				return false
		end
	end

	def before_validation_on_create; create_mask end

	def after_create
		NewsfeedItem.new(:user_id => created_by_id, :text => "created account <a href=\"#{CP_PREFIX}/accounts/profile/#{self.mask}\">#{self.name}</a>", :account_id => self[:id]).save

		permission = UserPermission.new
		permission.user = created_by
		permission.account = self
		permission.set_by_user = created_by
		permission.enable_all
		permission.save
	end

	def open_tickets
		Ticket.find(:all, :conditions => [ "account_id = ? AND status != 'Closed'", self.id ])
	end
	
	def method_missing(sym, *args, &block)
		sym_str = sym.to_s
		if sym_str[0, 3] == "md_"
			@metadata ||= {}
			
			if sym_str[-1, 1] != "="
				return @metadata[sym_str] if @metadata[sym_str] != nil
				metadata = AccountMetadata.find(:first, :conditions => { :keyword => sym_str, :account_id => self.id })
				return metadata ? metadata.value : nil
			else
				keyword = sym_str[0, sym_str.length-1]
				@metadata[keyword] = args[0]
				logger.error "Setting #{keyword} to #{args[0]} #{args.inspect}"
				
				return
			end
		else
			super(sym, *args, &block)
		end
	end
	
	def after_save
		@metadata ||= {}
		@metadata.each do |keyword, value|
			metadata = AccountMetadata.find(:first, :conditions => { :keyword => keyword, :account_id => self.id })
			metadata = AccountMetadata.new(:account_id => self.id, :keyword => keyword, :value => value) if ! metadata
			if value == nil
				metadata.destroy
			else
				metadata.save
			end
		end
	end

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
