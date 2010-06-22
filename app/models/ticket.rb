class Ticket < ActiveRecord::Base
	belongs_to :account
	belongs_to :server
	belongs_to :assigned_to, :class_name => 'User'
	belongs_to :created_by, :class_name => 'User'
#	belongs_to :service
	has_many :ticket_updates

	attr_protected :mask, :account_id, :server_id, :created_by_id

	TICKET_STATUS = [ 'New', 'Assigned', 'Unassigned', 'Awaiting Feedback', 'Closed', 'Reopened' ]
	TICKET_PRIORITY = %w(Urgent High Normal Low)
	TICKET_TYPE = [ 'General', 'Support', 'Sales', 'Beyond Monitoring' ]

	validates_presence_of :ticket_type, :mask, :created_by_id
	validates_uniqueness_of :mask
	validates_inclusion_of :status, :in => TICKET_STATUS.map {|value| value}, :message => 'is not valid'
	validates_inclusion_of :priority, :in => TICKET_PRIORITY.map {|value| value}, :message => 'is not valid'
	validates_inclusion_of :ticket_type, :in => TICKET_TYPE.map {|value| value}, :message => 'is not valid'
	
	def deliver_ticket_notification!
		TicketNotification.deliver_new_ticket(self)
	end

	def from_line
		created_by != nil ? created_by.name : from
	end

	def last_update
		ticket_update = TicketUpdate.find_by_ticket_id(self.id, :order => 'created_at DESC')
		if ticket_update != nil
			return { :time => ticket_update.created_at, :user => ticket_update.user }
		else
			return { :time => self.created_at, :user => self.created_by }
		end
	end

	def allowed_for(user)
		if ! allowed_for? user
			raise "Not available for this user"
		end
	end
	
	def allowed_for?(user)
		user.id == self.created_by_id or (self.account and self.account.allowed_for? user, :tickets)
	end
	
	def self.search(q)
		p = "%#{q}%"
		result = find(:all, :conditions => [ 'mask like ? or subject like ? or text like ? or status like ?', p, p, p, p ])
		
		TicketUpdate.find(:all, :conditions => [ 'value like ? or comment like ?', p, p ]).each {|m| result << m.ticket }
		
		result
	end

	def after_create
		NewsfeedItem.new(:user_id => created_by_id, :text => "created ticket <a href=\"#{CP_PREFIX}/tickets/view/#{self.mask}\">##{self.mask}</a>", :ticket_id => self[:id]).save
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
