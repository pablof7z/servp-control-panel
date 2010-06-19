require 'binarycanary.rb'

binary_canary = BinaryCanary::Session.new('test')
servers = binary_canary.list_servers
if servers.has_error?
	if servers.errors[0].error.code == 'InvalidAPIKey'
		puts "Invalid API Key"
	else
		puts servers.errors[0].error.text
	end
else
	servers.each do |server|
		puts server.server.serverid
	end
end

