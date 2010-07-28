class DashboardController < ApplicationController
  def index
    user = NewsfeedItem.find(:all, :conditions => { :user_id => @user.id })
    accounts = []
    servers = []
    tickets = []
    @user.accounts.each do |account|
      permission = UserPermission.find(:first, :conditions => { :user_id => @user.id, :account_id => account.id })
      next if permission == nil

      accounts = NewsfeedItem.find(:all, :conditions => [ "user_id != ? AND account_id = ?", @user.id, account.id ])
      account.servers.each {|server| servers = NewsfeedItem.find(:all, :conditions => [ "user_id != ? AND server_id = ?", @user.id, server.id ]) } if permission.servers
      account.tickets.each {|ticket| tickets = NewsfeedItem.find(:all, :conditions => [ "user_id != ? AND ticket_id = ?", @user.id, ticket.id ]) } if permission.tickets
    end

    @newsfeed = user | accounts | servers | tickets
    @newsfeed.sort! {|a, b| b.created_at <=> a.created_at }
  end
end
