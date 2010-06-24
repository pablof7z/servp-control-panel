# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :accept_login
  before_filter :require_login
  before_filter :get_open_tickets

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  helper_method :current_user

  def newsfeed_add(text, opts)
  	newsfeed = NewsfeedItem.new(opts)
	newsfeed.text = text
	newsfeed.user = @user
	newsfeed.save
  end

  protected

	def accept_login
		@user = current_user
		@account = Account.find_by_mask(session[:account]) || @user.accounts[0]
		if ! @account.allowed_for? current_user
			flash[:warning] = "Resource unavailable, try again later or contact us if you think this is something we should be aware of."
			@account = @user.accounts[0]
		end
		session[:account] = @account.mask

		if params[:controller].downcase.match(/admin/) != nil
			if !@user.admin? and params[:action].downcase.match(/remove_su/) == nil
				flash[:warning] = "Resource unavailable, try again later or contact us if you think this is something we should be aware of."
				redirect_to :controller => '/dashboard'
			end
		end
		
		rescue
			true
	end

  def require_login
  	if ! @user
		session[:intended_url] = request.request_uri
		path = cookies[:user] != nil ? login_path : register_path
		redirect_to path and return
	end
  end

  def get_open_tickets
  	if current_user != nil
	  	@my_open_tickets = @user.open_tickets if @user
		@account_open_tickets = @account.open_tickets if @user
	end
  end

  private

  def current_user_session
  	return @current_user_session if defined?(@current_user_session)
	@current_user_session = UserSession.find
  end

  def current_user
  	return @current_user if defined?(@current_user)
	@current_user = current_user_session && current_user_session.record
  end
end
