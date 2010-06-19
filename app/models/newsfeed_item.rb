class NewsfeedItem < ActiveRecord::Base
	belongs_to :user
#	belongs_to :account
#	belongs_to :server
	belongs_to :ticket

	validates_presence_of :user_id, :text
end
