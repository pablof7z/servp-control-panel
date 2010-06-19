class TicketUpdate < ActiveRecord::Base
	belongs_to :ticket
	belongs_to :user

	validates_presence_of :ticket_id, :user_id

	def after_create
		NewsfeedItem.new(:user_id => user_id, :text => "has modified ticket <a href=\"#{CP_PREFIX}/tickets/view/#{ticket.mask}\">##{ticket.mask}</a>").save
	end
end
