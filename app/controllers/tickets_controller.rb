class TicketsController < ApplicationController
	before_filter :validate_can_access_tickets
	before_filter :load_ticket, :only => [ :view, :update ]

  def index
  	@ticket_groups = []

	my_tickets = { :title => 'My Tickets' }
	my_tickets[:tickets] = Ticket.find(:all, :conditions => { :created_by_id => @user.id }, :order => 'created_at DESC')
	
	account_tickets = { :title => "Others' Tickets on account #{@account.name}" }
	account_tickets[:tickets] = []
	account_tickets[:tickets] = Ticket.find(:all, :conditions => [ 'account_id = ? AND created_by_id != ?', @account.id, @user.id ], :order => 'created_at DESC')

	others_tickets = { :title => "Others' Tickets on other accounts" }
	others_tickets[:tickets] = []

	@user.accounts.each do |account|
		if account.id != @account.id
			others_tickets[:tickets] = others_tickets[:tickets] + Ticket.find(:all, :conditions => [ 'account_id = ? AND created_by_id != ?', account.id, @user.id ], :order => 'created_at DESC')
		end
	end

	@ticket_groups << my_tickets
	@ticket_groups << account_tickets
	@ticket_groups << others_tickets
  end

  def new
  	@ticket = Ticket.new
  end

  def create
  	debugger
  	@ticket = Ticket.new(params[:ticket])
	@ticket[:created_by_id] = @user.id
	@ticket[:from]       = "#{@user.name} <#{@user.email}>"
	@ticket[:ticket_type]= 'General'

	if params[:ticket_about].blank? == false
		a = params[:ticket_about].split(':')
		
		if a[0] == 'account'
			account = Account.find_by_mask(a[1])			
			@ticket.account = account
		elsif a[0] == 'server'
			server = Server.find_by_mask(a[1])
			@ticket.account = server.account
			@ticket.server = server
		end
	end

	if @ticket.save
		flash[:notice] = "Ticket created successfully."
		@ticket.deliver_ticket_notification!
		redirect_to :action => 'view', :id => @ticket.mask
	else
		flash[:warning] = "Ticket not submited."
		render :action => 'new'
	end
  end

  def view
  	@ticket_update = TicketUpdate.new
  end

  def update
	@ticket_update = TicketUpdate.new(params[:ticket_update])
	@ticket_update.ticket = @ticket
	@ticket_update.user = @user
	
	case params[:status]
		when 'open':
			@ticket_update.keyword = 'status'
			@ticket_update.value = 'reopened'
			@ticket.status = 'Reopened'
			if ! @ticket.save or ! @ticket_update.save
				flash[:error] = 'The ticket could not be modified.'
				render :action => 'view', :ticket => @ticket[:mask] and return
			end
		when 'closed':
			@ticket_update.keyword = 'status'
			@ticket_update.value = 'closed'
			@ticket.status = 'Closed'
			if ! @ticket.save or ! @ticket_update.save
				flash[:error] = 'The ticket could not be modified.'
				render :action => 'view', :ticket => @ticket[:mask] and return
			end
		when 'unchanged':
			if ! @ticket_update.save
				flash[:error] = 'The ticket could not be modified.'
				render :action => 'view', :ticket => @ticket[:mask] and return
			end
		else
			flash[:error] = 'An invalid status change was requested.'
			render :action => 'view', :ticket => @ticket[:mask] and return
	end

	redirect_to :action => 'view', :id => @ticket[:mask]

	rescue
		flash[:error] = 'Ticket unavailable'
		redirect_to :action => 'view', :id => params[:id] and return
  end

  private

  def load_ticket
  	@ticket = Ticket.find_by_mask(params[:id])
	@ticket.allowed_for current_user

	# Trying to use a ticket of some other account
	if @ticket.account and @ticket.account.id != @account.id
		session[:switch_url] = request.request_uri
		redirect_to :controller => 'account', :action => 'switch', :id => @ticket.account.mask
	end

	rescue
		flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
		redirect_to :action => 'index'
  end

  def validate_can_access_tickets
  	@account.allowed_for current_user, :tickets
	rescue
		flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
		redirect_to :action => 'index'
  end
end
