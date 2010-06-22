class User < ActiveRecord::Base
	has_many :contact_details
	has_many :accounts
	has_many :tickets
	has_many :newsfeed_items
	has_many :user_permissions, :dependent => :destroy
	has_many :accounts, :through => :user_permissions

	attr_protected :id, :mask

	validates_presence_of :mask
	validates_uniqueness_of :mask

	acts_as_authentic

	def daemon?
		self.role == 'daemon'
	end

	def admin?
		self.role == 'admin' or self.role == 'superadministrator'
	end

	def superadmin?
		self.role == 'superadministrator'
	end
	
	def deliver_new_user!
		UserNotifier.deliver_new_user(self)
	end

	def deliver_password_reset_instructions!
		reset_perishable_token!
		UserNotifier.deliver_password_reset_instructions(self)
	end

	def open_tickets
		Ticket.find(:all, :conditions => [ "created_by_id = ? AND status != 'Closed' AND account_id IS NULL", self.id ])
	end
	
	def self.search(q)
		p = "%#{q}%"
		result = find(:all, :conditions => [ 'name like ? or country like ? or username like ? or email like ? or mask like ?', p, p, p, p, p ])
		
		ContactDetail.find(:all, :conditions => [ 'information like ?', p ]).each {|m| result << m.user }
		
		result
	end

	def after_create
		contact_detail = ContactDetail.new
		contact_detail.user = self
		contact_detail.mechanism = 'Email'
		contact_detail.information = self.email
		contact_detail.save
	end

	def before_update
		user = User.find_by_id(self.id)
		contact_detail = ContactDetail.find(:all, :conditions => { :mechanism => 'Email', :user_id => self.id, :information => user.email } )
		begin
			contact_detail[0].information = self.email
			contact_detail[0].save
		rescue
		end
		true
	end

	def before_validation_on_create; create_mask end

	private

	def create_mask
		a = ("0".."9").to_a
		while true
			s = ""
			1.upto((7..9).to_a[rand(3)]) { |i| s << a[rand(a.size-1)] }
			break if User.find_by_mask(s) == nil
		end
		self.mask = s
	end
end
