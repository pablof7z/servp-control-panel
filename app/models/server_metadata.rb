class ServerMetadata < ActiveRecord::Base
	belongs_to :server

	validates_presence_of :server_id, :keyword, :value
end
