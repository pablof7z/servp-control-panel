class AccountMetadata < ActiveRecord::Base
	belongs_to :account
	
	validates_presence_of :account_id, :keyword
	
	attr_accessor :set_by_user
end
