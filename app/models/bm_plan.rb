class BmPlan < ActiveRecord::Base
	belongs_to :plan, :dependent => :destroy
	
	validates_presence_of :plan_id, :included_cats, :additional_cat_price_cents
	
	attr_protected :plan_id, :included_cats, :additional_cat_price_cents
end
