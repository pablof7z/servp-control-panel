class Admin::ServersController < ApplicationController
	active_scaffold :server
	layout 'layouts/active_scaffold'
end
