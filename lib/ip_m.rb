require 'scanf.rb'

def is_ip(s)
	ip = s.split(/\./)

	return false if s.match(/\b(?:\d{1,3}\.){3}\d{1,3}\b/) == nil

	p = s.scanf('%3d.%3d.%3d.%3d')

	for i in (0..3) do return false unless p[i].to_i < 255 end
	for i in [1, 2] do return false unless p[i].to_i >= 0 end
	for i in [0, 3] do return false unless p[i].to_i > 0 end

	return true
end

def ip2country(ip_address, long_version = true)
	ip = ip_address.split(/\./)
	raise "Not a valid IP address" if ip.length != 4

	ip = ip[0].to_i * 16777216 + ip[1].to_i * 65536 + ip[2].to_i * 256 + ip[3].to_i

	if ! File.exists?("/opt/serverprotectors/data/ip2country.csv")
		logger.error("File /opt/serverprotectors/data/ip2country doesn't eixst")
		raise "Unable to satisfy"
	end

	File.open("/opt/serverprotectors/data/ip2country.csv") do |f|
		low = 0
		high = f.stat.size
		f.seek(high / 2)
		while true
			while ((a = f.getc) != 10)
				f.seek(-2, IO::SEEK_CUR)
			end
			pos = f.pos
			l = f.readline
			line = l.split(",")
			low_range = line[0][1..-2].to_i
			high_range = line[1][1..-2].to_i
			if (low_range > ip)
				high = pos
				offset = (f.pos - pos) + ((high - low) / 2)
				f.seek(-offset, IO::SEEK_CUR)
			elsif (high_range < ip)
				low = f.pos
				f.seek((high-low) / 2, IO::SEEK_CUR)
			else
				a = line[4][1..-2] if long_version == false
				a = line[6][1..-3] if long_version == true
				return a.titleize
			end
		end
	end
end

