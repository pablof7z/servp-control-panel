class BmSubscriptionPeriod < ActiveRecord::Base
	belongs_to :subscription_period

	validates_presence_of :total_cats, :used_cats, :additional_cat_price_cents
end
