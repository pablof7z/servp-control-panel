require 'rubygems'
require 'builder'
require 'net/https'
require 'rexml/document'

module BinaryCanary
	class Account
		
	end
	
	class Server
		attr_reader :server_id, :country_id, :organization_id, :hostname,
		            :contact_name, :contact_email, :contact_address, :contact_address2,
		            :contact_city, :contact_postal_code, :contact_province,
		            :server_status, :server_timezone
	end
	
	class Response < Hash
		def method_missing(name, *args)
			if name.to_s[-1, 1] != "="
				self[name.to_s]
			else
				self[name.to_s] = args[0]
			end
		end
		
		def has_error?
			return self["errors"] != nil
		end
	end

	class Session
	
		TARGET = "http://binarycanary.com/api/"
		
		attr_reader :api_key
		
		def initialize(api_key)
			@api_key = api_key
		end
		
		def get_server(id)
			resp = call('getServer', "Server" => { "ID" => id })
		end
	
		def list_servers
			resp = call('listServers', "Server" => nil)
			resp
		end
	
		private
	
		def call(a, *args)
			xml = Builder::XmlMarkup.new
			xml.instruct!
			xml.BinaryCanary {
				xml.APIKey @api_key
				xml.Method a
				xml.Parameters { |x|
					call_parameter x, args
				}
			}
			
			url = URI.parse TARGET
			
#			res = Net::HTTP.post_form(url, {:BinaryCanary_XML => xml.target! })
#			puts res
			
			req = Net::HTTP::Post.new(url.path)
			req.form_data = { :BinaryCanary_XML => xml.target! }
			http = Net::HTTP.new(url.host, url.port)
#			http.use_ssl = 1
			res = http.start do |http|
				http.request(req)
			end
			
			puts res.body
			
			xml_parse = REXML::Document.new res.body
			
			ret = Response.new
			
			REXML::XPath.each(xml_parse, '//BinaryCanary/*') do |element|
				ret[element.name.downcase] ||= []
				element.elements.each do |i|
					ret[element.name.downcase] << parse(i)
				end
			end
			
			puts ret.inspect
			
			ret
		end
		
		def call_parameter(xml, arg)
			arg.each do |k, v|
				if k.is_a? Hash
					call_parameter(xml, k)
				else
					xml.__send__ k, v
				end
			end
		end
				
		def parse(element)
			ret = Response.new
			ret[element.name.downcase] = Response.new
			
			element.elements.each do |i|
				if i.elements[1] != nil
					ret[element.name.downcase].merge! parse(i)
				else
					ret[element.name.downcase][i.name.downcase] = i.text
				end
			end
			
			return ret
		end
	end
end

class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

