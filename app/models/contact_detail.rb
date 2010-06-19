class ContactDetail < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :user_id, :mechanism, :information, :mask
	validates_uniqueness_of :information, :scope => [ :user_id, :mechanism ], :message => "that information has already been added"

	MECHANISMS = [ 'Email', 'Telephone', 'Address', 'AIM', 'MSN', 'Skype', 'Facebook', 'Twitter' ]

	def allowed_for(user)
		if ! allowed_for? user
			raise "Not available for this user"
		end
	end
	
	def allowed_for?(user)
		user.id == self.user_id
	end

	def before_destroy
		# Check if this is the last email contact or the last contact
		if self.user.contact_details.size == 1 or
		   (self.mechanism == 'Email' and ContactDetail.find(:all, :conditions => { :user_id => self.user.id, :mechanism => 'Email' } ).size == 1)
			return false
		end
	end

	def after_create
		NewsfeedItem.new(:user_id => user_id, :text => "has new contact information").save
	end

	def after_destroy
		NewsfeedItem.new(:user_id => user_id, :text => "has removed contact information").save
	end

	def before_validation_on_create; create_mask end

	private

	def create_mask
		a = ("0".."9").to_a
		while true
			s = ""
			1.upto((7..9).to_a[rand(3)]) { |i| s << a[rand(a.size-1)] }
			break if ContactDetail.find_by_mask(s) == nil
		end
		self.mask = s
	end
end
