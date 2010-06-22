class TicketNotification < ActionMailer::Base
	default_url_options[:host] = "https://serverprotectors.com/cp"
	
	def new_ticket(ticket)
		subject "Server Protectors Ticket Confirmation"
		from	"Server Protectors <support@serverprotectors.com>"
		ticket.account.users.each do |users|
			users.contact_details.each do |contact_detail|
				next if contact_detail.mechanism != 'Email' or contact_detail.enabled != true
				recipients contact_detail.information
			end
		end
		bcc		"support@servp.com"
		sent_on	Time.now
		body :ticket => ticket, :url => default_url_options[:host]
	end
end
