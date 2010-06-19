class UserSessionsController < ApplicationController
	skip_before_filter :require_login, :only => [ :new, :create ]

  def new
  	@user_session = UserSession.new
  	@user_session.username = cookies[:user]
  end

  def create
  	@user_session = UserSession.new(params[:user_session])
	if @user_session.save
		flash[:notice] = "Successfully login."
		redirect_to session[:intended_url] || root_path
		session[:intended_url] = nil
		cookies[:user] = @user_session.username
	else
		render :action => 'new'
	end
  end

  def destroy
  	@user_session = UserSession.find
	@user_session.destroy
	flash[:notice] = "Successfully logout."
	redirect_to '/'
	session[:account] = nil
  end
end
