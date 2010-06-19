class Admin::BmPlansController < ApplicationController
	active_scaffold :bm_plan
	
	layout 'layouts/active_scaffold'
end
