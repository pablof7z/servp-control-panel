class Admin::PlansController < ApplicationController
	active_scaffold :plan do |config|
#		list.columns.exclude :servers, :subscription, :bm_data
#		config.nested.add_link("Servers", [:servers])
#		config.actions.exclude :nested
	end
	
	layout 'layouts/active_scaffold'
end
