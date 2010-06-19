class BmSubscriptionMetadata < ActiveRecord::Base
	belongs_to :bm_subscription
	
	validates_presence_of :bm_subscription_id, :keyword
end
