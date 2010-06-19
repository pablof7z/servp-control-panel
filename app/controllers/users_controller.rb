class UsersController < ApplicationController
	skip_before_filter :require_login, :only => [ :new, :create, :forgot, :reset ]
	before_filter :load_user_using_perishable_token, :only => [ :reset ]

  def new
  	@user = User.new
  end

  def create
  	params[:user][:username] = params[:user][:email]
  	@user = User.new(params[:user])
	@account = Account.new(params[:account])
	@account.name = params[:user][:name] if @account.name.blank?
	@account.name = params[:user][:username] if @account.name.blank?
	if @user.save
		@account.created_by = @user
		@account.save

		flash[:notice] = "Registration successful."
		redirect_to session[:intended_url] || root_path
		session[:intended_url] = nil
		
		@user.deliver_new_user!
	else
		render :action => 'new'
	end
  end

  def profile
  	if request.post?
		if @user.update_attributes(params[:user])
			flash[:notice] = "Successfully updated user."
			redirect_to root_url
		end
	end
  end

  def forgot
  	if request.post?
		@user = User.find_by_email(params[:email])

		if @user
			@user.deliver_password_reset_instructions!
			flash[:notice] = "Instructions to reset your password have been emailed to you."
			redirect_to root_path
		else
			flash[:notice] = "The email address is not in our records, you can use it to sign up."
			redirect_to register_path
		end
	end
  end

  def reset
  	if request[:user] != nil
		@user.password = params[:user][:password]
		@user.password_confirmation = params[:user][:password_confirmation]
		if @user.save
			flash[:notice] = "Password successfully reset"
			redirect_to root_path
		else
			render :action => :reset
		end
	else
		render
	end
  end

  private

  def load_user_using_perishable_token
  	@user = User.find_using_perishable_token(params[:id])
	if @user == nil
		flash[:notice] = "We couldn't find your user with that information, perhaps the URL you are using was not copied right into the browser"
		redirect_to login_path
	end
  end
end
