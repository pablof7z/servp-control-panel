class UserPermission < ActiveRecord::Base
	belongs_to :user
	belongs_to :account
	belongs_to :set_by_user, :class_name => 'User'

	validates_uniqueness_of :user_id, :scope => :account_id, :message => 'already belongs to the account'
	validates_presence_of :user_id, :account_id

	attr_protected :user_id, :account_id, :set_by_user_id

	def enable_all
		tickets = billing = users = reports = servers = true
	end

	def after_create
		NewsfeedItem.new(:user_id => set_by_user, :text => "has set an account permission for #{set_by_user_id == user_id ? "themselves" : user.name} on account #{account.name}", :account_id => account_id).save
	end

	def after_update
		NewsfeedItem.new(:user_id => set_by_user, :text => "has changed an account permission for #{set_by_user_id == user_id ? "themselves" : user.name} on account #{account.name}", :account_id => account_id).save
	end

	def before_destroy
		NewsfeedItem.new(:user_id => set_by_user, :text => "has removed account permissions for #{set_by_user_id == user_id ? "themselves" : user.name} on account #{account.name}", :account_id => account_id).save
	end
end
