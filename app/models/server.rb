class Server < ActiveRecord::Base
	belongs_to :account
	has_many :tickets
	belongs_to :created_by, :class_name => 'User'
	has_many :server_metadatas
	has_many :subscriptions

	attr_protected :account_id, :mask, :private_notes, :enabled

	validates_presence_of :account_id, :mask, :hostname, :created_by_id
	validates_length_of :name, :within => 5..32
	validates_uniqueness_of :name, :scope => :account_id, :message => 'is already being used by another server in this account'
	validates_uniqueness_of :mask

	attr_accessor :user_id

	TYPES = [
		[ 'Dedicated Server', 'dedicated' ],
		[ 'Virtual Private Server (VPS)', 'vps' ],
		[ 'Cloud Computing Instance', 'cloud' ],
		[ 'Shared Virtual Host', 'vhost' ],
		[ 'Other', 'other' ],
		[ 'Unknown', 'unknown' ]
	]

	def allowed_for(user, action=:servers)
		if ! allowed_for? user
			raise "Not available for this user"
		end
	end
	
	def allowed_for?(user, action=:servers)
		account.allowed_for? user, action
	end
	
	def bm_subscription
		subscriptions.each do |subscription|
			logger.error "#{subscription.plan.service.name}"
			return subscription if subscription.plan.service.name == 'Beyond Monitoring'
		end
		
		return nil
	end
	
	def self.search(q)
		p = "%#{q}%"
		result = find(:all, :conditions => [ 'name like ? or private_notes like ? or public_notes like ? or description like ? or hostname like ? or mask like ?', p, p, p, p, p, p ])
		
		ServerMetadata.find(:all, :conditions => [ 'value like ?', p ]).each {|m| result << m.server }
		
		result
	end

	def method_missing(sym, *args, &block)
		sym_str = sym.to_s
		if sym_str[0, 3] == "md_"
			if sym_str[-1, 1] != "="
				metadata = ServerMetadata.find(:first, :conditions => { :keyword => sym_str, :server_id => self.id })
				return metadata ? metadata.value : nil
			else
				keyword = sym_str[0, sym_str.length-1]
				metadata = ServerMetadata.find(:first, :conditions => { :keyword => keyword, :server_id => self.id })
				if ! metadata
					metadata = ServerMetadata.new(:keyword => keyword, :server_id => self.id)
				end
				
				logger.error "Setting #{keyword} to #{args[0]} #{args} #{args.inspect}"
				
				metadata.value = args[0]
				metadata.save
				return
			end
		else
			super(sym, *args, &block)
		end
	end

	def after_create
		NewsfeedItem.new(:user_id => user_id, :text => "created server <a href=\"#{CP_PREFIX}/servers/edit/#{mask}\">#{name}</a>", :server_id => id).save
	end

	def after_update
		NewsfeedItem.new(:user_id => user_id, :text => "changed information about server <a href=\"#{CP_PREFIX}/servers/edit/#{mask}\">#{name}</a>", :server_id => id).save
	end

	def before_destroy
		NewsfeedItem.new(:user_id => user_id, :text => "removed server <a href=\"#{CP_PREFIX}/servers/edit/#{mask}\">#{name}</a> from account #{account.name}", :server_id => id).save
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
