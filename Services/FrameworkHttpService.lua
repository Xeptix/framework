-- Framework's HttpService. Posts and gets with paramaters to identify the server, including api key (which must be present)

return {"FrameworkHttpService", "FrameworkHttpService", {
	_StartService = function(self, a,b,c,d,e,f,g,h,i,j,k,l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		self:SetProperty("HttpEnabled", false)
		self:SetProperty("_", game:GetService("HttpService"))
		local passed, msg = pcall(function()
			self:Get("http://0.0.0.0", {})
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
	Get = function(self, url, opt)
		local result
		pcall(function()
			result = self._:GetAsync(self:AppendQueryString(url, self:Encode(self:QueryString({
				ServerId = game.FrameworkInternalService.ServerId,
				JobId = game.JobId or "0",
				PlaceId = game.PlaceId or "0",
				CreatorId = game.CreatorId or "0",
				CreatorType = tostring(game.CreatorType),
				VIPServerId = game.VIPServerId or 0,
				VIPServerOwnerId = game.VIPServerOwnerId or 0
			}))), true)
		end)
		
		if result and opt.json then
			pcall(function()
				result = seelf._:JSONDecode(result)
			end)
		end
		
		return result
	end,
	Post = function(self, url, data, opt)
		local result
		pcall(function()
			result = self._:PostAsync(self:AppendQueryString(url, self:Encode(self:QueryString({
				ServerId = game.FrameworkInternalService.ServerId,
				JobId = game.JobId or "0",
				PlaceId = game.PlaceId or "0",
				CreatorId = game.CreatorId or "0",
				CreatorType = tostring(game.CreatorType),
				VIPServerId = game.VIPServerId or 0,
				VIPServerOwnerId = game.VIPServerOwnerId or 0,
				
			}))), data)
		end)
		
		if result and opt.json then
			pcall(function()
				result = seelf._:JSONDecode(result)
			end)
		end
		
		return result
	end,
	QueryString = function(self, items)
		game.FrameworkService:CheckArgument(debug.traceback(), "QueryString", 1, items, "table")
		
		return "?" .. table.format(items, "%i=%v", "&")--todo: somehow encode these values lol
	end,
	AppendQueryString = function(self, url, query)
		game.FrameworkService:CheckArgument(debug.traceback(), "AppendQueryString", 1, url, "string")
		game.FrameworkService:CheckArgument(debug.traceback(), "AppendQueryString", 2, query, "string")
		
		if not url:match("?.*") then
			return url .. query
		else
			return url .. "&" .. query:sub(2)
		end
	end,
	Encode = function(self, url)
		game.FrameworkService:CheckArgument(debug.traceback(), "Encode", 1, url, "string")
		if url:sub(1,1) == "?" then
			url = url:gsub("?", "THISISREALLYBADCODEBUTITREPLACESDAQUESTIONMARKSOOHWELL")
			:gsub("=", "THISISREALLYBADCODEBUTITREPLACESDAEQUALSIGNSOOHWELL")
			:gsub("&", "THISISREALLYBADCODEBUTITREPLACESDAANDSIGNSOOHWELL")
			return self._:UrlEncode(url):gsub("THISISREALLYBADCODEBUTITREPLACESDAQUESTIONMARKSOOHWELL", "?")
			:gsub("THISISREALLYBADCODEBUTITREPLACESDAEQUALSIGNSOOHWELL", "=")
			:gsub("THISISREALLYBADCODEBUTITREPLACESDAANDSIGNSOOHWELL", "&")
		end
		return self._:UrlEncode(url)
	end,
	Decode = function(self, url)
		game.FrameworkService:CheckArgument(debug.traceback(), "Decode", 1, url, "string")
		return self._:UrlDecode(url)
	end,
}}