class BmSubscription < ActiveRecord::Base
	belongs_to :subscription, :dependent => :delete
	has_one :plan, :through => :subscription
	has_one :server, :through => :subscription
	
	attr_protected :subscription_id
	
	BM_SERVICE_PROVIDERS = [
		[ 'Pingdom', 'pingdom' ],
		[ 'Binary Canary', 'binary canary' ],
		[ 'Sysmonitors', 'sysmonitors' ],
		[ 'Site24x7', 'site24x7' ],
		[ 'Unknown', 'unknown' ]
	]
	
	validates_presence_of :subscription_id
	validates_uniqueness_of :subscription_id
	
	validates_inclusion_of :service_provider, :in => BM_SERVICE_PROVIDERS.map {|di, value| value}, :message => 'is not valid'

#	def before_save
#		if service_provider == 'sysmonitors'
#			self.sm_token ||= create_token
#		end
#	end

	def method_missing(sym, *args, &block)
		puts "#### HERE"
		sym_str = sym.to_s
		if sym_str[0, 3] == "bm_"
			@metadata ||= {}
			
			if sym_str[-1, 1] != "="
				return @metadata[sym_str] if @metadata[sym_str] != nil
				metadata = BmSubscriptionMetadata.find(:first, :conditions => { :keyword => sym_str, :bm_subscription_id => self.id })
				return metadata ? metadata.value : nil
			else
				keyword = sym_str[0, sym_str.length-1]
				@metadata[keyword] = args[0]
				
#				metadata = BmSubscriptionMetadata.find(:first, :conditions => { :keyword => keyword, :bm_subscription_id => self.id })
#				if ! metadata
#					metadata = BmSubscriptionMetadata.new(:keyword => keyword, :bm_subscription_id => self.id)
#				end
#				
#				metadata.value = args
#				metadata.save
				return
			end
		else
			super(sym, *args, &block)
		end
	end

	def after_save
		@metadata.each do |keyword, value|
			metadata = BmSubscriptionMetadata.find(:first, :conditions => { :keyword => keyword, :bm_subscription_id => self.id })
			metadata = BmSubscriptionMetadata.new(:bm_subscription_id => self.id, :keyword => keyword, :value => value) if ! metadata
			if value == nil
				metadata.destroy
			else
				metadata.save
			end
		end
	end

	private

	def create_token
		c = ("a".."z").to_a
		d = c + ("0".."9").to_a
		s = ""
		1.upto(32) { |i| s << d[rand(d.size-1)] }

		return s
	end
end
