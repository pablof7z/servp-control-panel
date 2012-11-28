class Admin::DashboardController < ApplicationController
	def index
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
