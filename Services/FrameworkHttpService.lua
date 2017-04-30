-- Framework's HttpService. Posts and gets with paramaters to identify the server, including api key (which must be present)

return {"FrameworkHttpService", "FrameworkHttpService", {
	_StartService = function(self, a,b,c,d,e,f,g,h,i,j,k,l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		self:SetProperty("HttpEnabled", false)
		self:SetProperty("HttpConnected", false)
		self:SetProperty("_", game:GetService("HttpService"))
		
		if game:Is("Server") and game:GetFrameworkModule().WebConnection.Connection.Value then
			game:SetProperty("Info", "")
			local passed, msg = pcall(function()
				local x = self:Get("server", {json=true})
				
				game:SetProperty("Info", x.Info)
				game:LockProperty("Info", 2)
				game.FrameworkInternalService:SetProperty("ServerId", x.ServerId)
				game.FrameworkInternalService:LockProperty("ServerId", 2)
			end)
			
			if passed then
				self.HttpEnabled = true
			else--
				if msg:lower() ~= "http requests are not enabled" then
					self.HttpEnabled = true
				end
			end
			
			if self.HttpEnabled then
				game.FrameworkInternalService:Report("Server " .. game.Info .. " is connected to the website and ready to make requests!")
			else 
				
			end
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Get = function(self, url, opt)
		if not opt then opt = {} end
		
		game.FrameworkService:LockServer(debug.traceback(), "Get")
		game.FrameworkService:LockConnected(debug.traceback(), "Get")
		
		local result
		local s, e = pcall(function()
			result = self._:GetAsync(self:AppendQueryString("https://api.xeptix.com/framework/v3/"..url.."/"..game:GetFrameworkModule().WebConnection.ApiKey.Value.."/"..game:GetFrameworkModule().WebConnection.GameKey.Value.."/"..game:GetFrameworkModule().WebConnection.SecretKey.Value, self:Encode(self:QueryString({
				ServerId = game.FrameworkInternalService.ServerId,
				JobId = game.JobId or "0",
				PlaceId = game.PlaceId or "0",
				CreatorId = game.CreatorId or "0",
				CreatorType = tostring(game.CreatorType),
				VIPServerId = game.VIPServerId or 0,
				VIPServerOwnerId = game.VIPServerOwnerId or 0,
			}))), true)
		end)
		
		if result and opt.json then
			if not pcall(function()
				result = self._:JSONDecode(result)
			end) then
				result = nil
			end
		end
		
		return result, e
	end,
	Post = function(self, url, data, opt)
		game.FrameworkService:LockServer(debug.traceback(), "Post")
		game.FrameworkService:LockConnected(debug.traceback(), "Post")
		
		if not opt then opt = {} end
		local result
		local s, e = pcall(function()
			result = self._:PostAsync(self:AppendQueryString("https://api.xeptix.com/framework/v3/"..url.."/"..game:GetFrameworkModule().WebConnection.ApiKey.Value.."/"..game:GetFrameworkModule().WebConnection.GameKey.Value.."/"..game:GetFrameworkModule().WebConnection.SecretKey.Value, self:Encode(self:QueryString({
				ServerId = game.FrameworkInternalService.ServerId,
				JobId = game.JobId or "0",
				PlaceId = game.PlaceId or "0",
				CreatorId = game.CreatorId or "0",
				CreatorType = tostring(game.CreatorType),
				VIPServerId = game.VIPServerId or 0,
				VIPServerOwnerId = game.VIPServerOwnerId or 0,
			}))), self._:JSONEncode(data))
		end) 
		
		if result and opt.json then
			if not pcall(function()
				result = self._:JSONDecode(result)
			end) then
				result = nil
			end
		end
		
		return result, e
	end,
	QueryString = function(self, items)
		game.FrameworkService:LockServer(debug.traceback(), "QueryString")
		game.FrameworkService:LockConnected(debug.traceback(), "QueryString")
		
		game.FrameworkService:CheckArgument(debug.traceback(), "QueryString", 1, items, "table")
		
		return "?" .. table.format(items, "%i=%v", "&")--todo: somehow encode these values lol
	end,
	AppendQueryString = function(self, url, query)
		game.FrameworkService:LockServer(debug.traceback(), "AppendQueryString")
		game.FrameworkService:LockConnected(debug.traceback(), "AppendQueryString")
		
		game.FrameworkService:CheckArgument(debug.traceback(), "AppendQueryString", 1, url, "string")
		game.FrameworkService:CheckArgument(debug.traceback(), "AppendQueryString", 2, query, "string")
		
		if not url:match("?.*") then
			return url .. query
		else
			return url .. "&" .. query:sub(2)
		end
	end,
	Encode = function(self, url)
		game.FrameworkService:LockServer(debug.traceback(), "Encode")
		game.FrameworkService:LockConnected(debug.traceback(), "Encode")
		
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
		game.FrameworkService:LockServer(debug.traceback(), "Decode")
		game.FrameworkService:LockConnected(debug.traceback(), "Decode")
		
		game.FrameworkService:CheckArgument(debug.traceback(), "Decode", 1, url, "string")
		return self._:UrlDecode(url)
	end,
}}