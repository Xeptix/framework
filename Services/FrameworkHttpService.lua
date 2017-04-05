-- Framework's HttpService. Posts and gets with paramaters to identify the server, including api key (which must be present)

return {"FrameworkHttpService", "FrameworkHttpService", {
	_StartService = function(self, a,b,c,d,e,f,g,h,i,j,k,l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		self:SetProperty("HttpEnabled", false)
		self:SetProperty("_", game:GetService("HttpService"))
		local passed, msg = pcall(function()
			self:Get("http://0.0.0.0")
		end)
		
		if passed then
			self.HttpEnabled = true
		else
			if msg:lower() ~= "http requests are not enabled" then
				self.HttpEnabled = true
			end
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Get = function(self, url, cache)
		return self._:GetAsync(url, cache)
	end,
	Post = function(self, ...)
		return self._:PostAsync(...)
	end,
	QueryString = function(self, items)
		game.FrameworkService:CheckArgument("QueryString", 1, items, "table")
		
		return "?" .. table.format(items, "%i=%v", "&")
	end,
	AppendQueryString = function(self, url, query)
		game.FrameworkService:CheckArgument("AppendQueryString", 1, url, "string")
		game.FrameworkService:CheckArgument("AppendQueryString", 2, query, "string")
		
		if not url:match("?.*") then
			return url .. query
		else
			return url .. "&" .. query:sub(2)
		end
	end,
	Encode = function(self, url)
		game.FrameworkService:CheckArgument("Encode", 1, url, "string")
		return self._:UrlEncode(url)
	end,
	Decode = function(self, url)
		game.FrameworkService:CheckArgument("Decode", 1, url, "string")
		return self._:UrlDecode(url)
	end,
}}
