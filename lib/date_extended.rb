class Date
	def self.first_day_of_next_month(yyyy=nil, mm=nil)
		today = Date.today

		yyyy = today.year if yyyy == nil
		mm = today.month if mm == nil

		d = Date.new(yyyy, mm)
		d += 42
		return Date.new(d.year, d.month)
	end

	def self.end_of_this_month(yyyy=nil, mm=nil)
		today = Date.today

		yyyy = today.year if yyyy == nil
		mm = today.month if mm == nil

		d = Date.new(yyyy, mm)
		d += 42

		return Date.new(d.year, d.month)-1
	end
	
	def self.days_in_month(mm=nil)
		return Date.end_of_this_month(nil, mm).day
	end
end

