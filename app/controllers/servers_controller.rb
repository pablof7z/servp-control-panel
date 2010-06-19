require 'ip_m'

class ServersController < ApplicationController
	before_filter :load_server, :except => [ :index, :new, :create, :validate_ip_addresses ]

  def index
  end

  def new
  	@server = Server.new
	@server.created_by = @user
	@hosting = @server.keyword('hosting')
	@ip_addresses = @server.keyword('ip_addresses')
	@ftp = {}
	@ssh = {}
	@control_panel  = {}
	@hosting = {}
	@others = {}
  end

  def create
  	@server = Server.new(params[:server])
	@server.user = @user
	if @server.save
		flash[:notice] = "Server created successfully."
		redirect_to :action => 'index'
	else
		render :action => 'new'
	end
  end

  def edit
  	@ftp = {
			:hostname => @server.md_ftp_hostname, :username => @server.md_ftp_username,
			:comments => @server.md_ftp_comments
		}
	@ssh = {
			:hostname => @server.md_ssh_hostname, :username => @server.md_ssh_username,
			:comments => @server.md_ssh_comments
		}
	@control_panel = {
			:url => @server.md_control_panel_url, :username => @server.md_control_panel_username,
			:comments => @server.md_control_panel_comments
		}
	@hosting = {}
	@others = {}
  end

  def update
  	if @server.update_attributes(params[:server])
		flash[:notice] = "Server updated successfully."
		redirect_to :action => 'index'
	else
		render :action => 'edit'
	end
  end
  
  def validate_ip_addresses
	a = params[:ip_addresses]
	l = a.split(/[, \n]/)

	@ips = []
	@non_ips = []
	@other_servers = []

	l.each do |c|
		next if c == ""
		if is_ip(c)
			@ips << c
			
			# Check if the IP exists in another server
			begin
				other_servers = Server.find_by_ip_from_hostname(c)
				
				other_servers.each do |server|
					@other_servers << c if server.mask != params[:server_id]
				end
			rescue
			end
		else
			@non_ips << c
		end
	end

	render :layout => false
  end

  private

  def load_server
  	@server = Server.find_by_mask(params[:id])
	@server.allowed_for current_user
	rescue
		flash[:warning] = 'Resource unavailable, try again later or contact us if you think this is something we should be aware of.'
		redirect_to :action => 'index'
  end
end
