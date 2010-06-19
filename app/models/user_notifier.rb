class UserNotifier < ActionMailer::Base
	default_url_options[:host] = "https://serverprotectors.com/cp"
	
	def new_user(user)
		subject "Server Protectors Sign Up"
		from	"Server Protectors"
		recipients user.email
		bcc		"support@servp.com"
		sent_on Time.now
		body :user => user
	end

	def password_reset_instructions(user)
		subject "Server Protectors Password Reset Instructions"
		from    "Server Protectors"
		recipients user.email
		sent_on Time.now
		body :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
	end

	private

	def edit_password_reset_url(perishable_token)
		"#{default_url_options[:host]}/user/reset/#{perishable_token}"
	end
end

