class Service < ActiveRecord::Base
	has_many :plans
	
	validates_presence_of :name
	validates_length_of :name, :within => 2..32
end
