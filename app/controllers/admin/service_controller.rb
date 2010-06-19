class Admin::ServiceController < ApplicationController
	active_scaffold :service
	layout 'layouts/active_scaffold'
end
