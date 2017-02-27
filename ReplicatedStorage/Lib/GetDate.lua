--[[
	File: GetDate.lua
	Author: Crazyman32
	Info: Allows you to format UNIX Timestamps into date format.
--]]







-- GetDate function
function GetDate(atick)
	local date = {}
	local months = {
		{"January", 31};
		{"February", 28};
		{"March", 31};
		{"April", 30};
		{"May", 31};
		{"June", 30};
		{"July", 31};
		{"August", 31};
		{"September", 30};
		{"October", 31};
		{"November", 30};
		{"December", 31};
	}
	local t = atick or tick()
	date.total = t
	date.seconds = math.floor(t % 60)
	date.minutes = math.floor((t / 60) % 60)
	date.hours = math.floor((t / 60 / 60) % 24)
	date.year = (1970 + math.floor(t / 60 / 60 / 24 / 365.25))
	date.yearShort = tostring(date.year):sub(-2)
	date.isLeapYear = ((date.year % 4) == 0)
	date.isAm = (date.hours < 12)
	date.hoursPm = (date.isAm and date.hours or (date.hours == 12 and 12 or (date.hours - 12)))
	if (date.hoursPm == 0) then date.hoursPm = 12 end
	if (date.isLeapYear) then
		months[2][2] = 29
	end
	do
		date.dayOfYear = math.floor((t / 60 / 60 / 24) % 365.25)
		local dayCount = 0
		for i,month in pairs(months) do
			dayCount = (dayCount + month[2])
			if (dayCount > date.dayOfYear) then
				date.monthWord = month[1]
				date.month = i
				date.day = (date.dayOfYear - (dayCount - month[2]) + 1)
				break
			end
		end
	end
	function date:format(str)
		str = str
			:gsub("#s", ("%.2i"):format(self.seconds))
			:gsub("#m", ("%.2i"):format(self.minutes))
			:gsub("#h", tostring(self.hours))
			:gsub("#H", tostring(self.hoursPm))
			:gsub("#Y", tostring(self.year))
			:gsub("#y", tostring(self.yearShort))
			:gsub("#a", (self.isAm and "AM" or "PM"))
			:gsub("#W", self.monthWord)
			:gsub("#M", tostring(self.month))
			:gsub("#d", tostring(self.day))
			:gsub("#D", tostring(self.dayOfYear))
			:gsub("#t", tostring(self.total))
		  -- ^ me gusta coding style -Xeptix
		return str
	end
	return date
end


return GetDate