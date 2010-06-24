class Admin::DashboardController < ApplicationController
	
	def index
	end
	
	def su
		@user = User.find_by_mask(params[:id])
		if @user.superadmin? and current_user.superadmin? == false
			flash[:warning] = "Resource unavailable, try again later or contact us if you think this is something we should be aware of."
			redirect_to :action => 'index'
			return
		end
		current_user_session.destroy
		UserSession.create!(@user)
		session[:su_user] = current_user.id
		session[:account] = @account.mask
#		current_user = @user
		
		flash[:notice] = "You are now logged in as #{@user.name} #{@user.username}"
		redirect_to :controller => '/dashboard'
	end
	
	def remove_su
		if session[:su_user] == nil
			flash[:warning] = "Resource unavailable, try again later or contact us if you think this is something we should be aware of."
			redirect_to :controller => '/dashboard', :action => 'index'
			return
		end
		
		@user = User.find_by_id(session[:su_user])
		current_user_session.destroy
		UserSession.create!(@user)
		session[:su_user] = nil
		session[:account] = @user.accounts[0].mask
		
		flash[:notice] = "You are back"
		redirect_to :action => 'index'
	end
	
	def search
		@results = {}
		
		if params[:q].blank? == false
			case params[:q]
				when ':accounts': @results[:account] = Account.find(:all)
				when ':billings': @results[:billing] = Billing.find(:all)
				when ':servers': @results[:server] = Server.find(:all)
				when ':tickets': @results[:ticket] = Ticket.find(:all)
				when ':users': @results[:user] = User.find(:all)
				else		
					@results[:account] = Account.search(params[:q])
					@results[:billing] = Billing.search(params[:q])
					@results[:server]  = Server.search(params[:q])
					@results[:ticket]  = Ticket.search(params[:q])
					@results[:user]    = User.search(params[:q])
					
					@results.delete_if {|keyword, results| results.size == 0 }
			end
		end
		
		render :layout => false
	end
end
