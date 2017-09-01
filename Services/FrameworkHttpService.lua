-- Framework's HttpService. Posts and gets with paramaters to identify the server, including api keys (which must be present)

return {"FrameworkHttpService", "FrameworkHttpService", {
	_StartService = function(self, a,b,c,d,e,f,g,h,i,j,k,l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		self:SetProperty("HttpEnabled", false)
		self:SetProperty("HttpConnected", false)
		self:SetProperty("Ready", false)
		self:SetProperty("_", game:GetService("HttpService"))
		self:SetProperty("PayloadDelay", 30)
		self:SetProperty("AutosaveDelay", 180)
		self:SetProperty("UnloadDelay", 300)
		self:SetProperty("StorageServicePerMin", 25)
		self:SetProperty("StorageServiceCap", 100)
		self:SetProperty("CounterServicePerMin", 25)
		self:SetProperty("CounterServiceCap", 100)
		self:SetProperty("CounterServiceRefetch", 60)
		self:SetProperty("FailedRequestRepeatDelay", 30)
		self:SetProperty("CachedItemExpieryTime", 300)
		self:SetProperty("PayloadEnabled", false)
		
		local function lock()
			self:LockProperty("PayloadDelay", 2)
			self:LockProperty("AutosaveDelay", 2)
			self:LockProperty("UnloadDelay", 2)
			self:LockProperty("PayloadEnabled", 2)
			self:LockProperty("HttpEnabled", 2)
			self:LockProperty("StorageServiceCap", 2)
			self:LockProperty("StorageServicePerMin", 2)
			self:LockProperty("CounterServiceCap", 2)
			self:LockProperty("CounterServicePerMin", 2)
			self:LockProperty("CounterServiceRefetch", 2)
			self:LockProperty("FailedRequestRepeatDelay", 2)
			self:LockProperty("CachedItemExpieryTime", 2)
			self:LockProperty("HttpConnected", 2)
		end
		--
		if game:Is("Server") and game:GetFrameworkModule().WebConnection.Connection.Value then
			spawn(function()
				if game:GetFrameworkModule():FindFirstChild("SID") then
					game:GetFrameworkModule().SID:Destroy()
				end
				
				game:SetProperty("Info", "")
				local passed, msg = pcall(function()
					local x, e = self:Get("server", {json=true, bypassConnectionLock=true, bypassWaiting=true})
					if type(x) ~= "table" then return "nah" end
					
					game:SetProperty("Info", x.Info or "")
					game:LockProperty("Info", 2)
					game.FrameworkInternalService:SetProperty("ServerId", x.ServerId or 0)
					game.FrameworkInternalService:LockProperty("ServerId", 2)
					
					self:SetProperty("HttpConnected", true)
					
					self.PayloadDelay = x.PayloadDelay
					self.AutosaveDelay = x.AutosaveDelay
					self.UnloadDelay = x.UnloadDelay
					self.StorageServicePerMin = x.StorageServicePerMin
					self.StorageServiceCap = x.StorageServiceCap
					self.CounterServicePerMin = x.CounterServicePerMin
					self.CounterServiceCap = x.CounterServiceCap
					self.FailedRequestRepeatDelay = x.FailedRequestRepeatDelay
					self.CachedItemExpieryTime = x.CachedItemExpieryTime
					self.CounterServiceRefetch = x.CounterServiceRefetch--
					self.PayloadEnabled = true
					
					local SID = Instance.new("StringValue", game:GetFrameworkModule())
					SID.Name = "SID"
					SID.Value = game.FrameworkInternalService.ServerId
					
					self:SetProperty("Ready", true)
				end)
				
				if passed and passed ~= "nah" then
					self.HttpEnabled = true
				else--
					pcall(function()
						game:SetProperty("Info", "")
						game:LockProperty("Info", 2)
						game.FrameworkInternalService:SetProperty("ServerId", 0)
						game.FrameworkInternalService:LockProperty("ServerId", 2)
					end)
					
					local SID = Instance.new("StringValue", game:GetFrameworkModule())
					SID.Name = "SID"
					SID.Value = game.FrameworkInternalService.ServerId
					
					if msg:lower() ~= "http requests are not enabled" then
						self.HttpEnabled = true
					end
				end
				
				if self.HttpEnabled then
					game.FrameworkInternalService:Report("Server " .. game.Info .. " is connected to the website and ready to make requests!")
				else 
					--?
				end
				
				lock()--
			end)
		elseif game:Is("Local") and game:GetFrameworkModule().WebConnection.Connection.Value then
			game:SetProperty("Info", "PID=" .. game.PlaceId .. "&SID=" .. game:GetFrameworkModule():WaitForChild("SID").Value)
			game:LockProperty("Info", 2)
			game.FrameworkInternalService:SetProperty("ServerId", game:GetFrameworkModule().SID.Value)
			game.FrameworkInternalService:LockProperty("ServerId", 2)
			
			lock()
		else
			game:SetProperty("Info", "PID=" .. game.PlaceId)
			game:LockProperty("Info", 2)
			game.FrameworkInternalService:SetProperty("ServerId", 0)
			game.FrameworkInternalService:LockProperty("ServerId", 2)
			
			lock()
		end
	

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	WaitUntilReady = function(self)
		if not self.Ready then
			repeat wait() until self.Ready
		end
		
		wait()
	end,
	Get = function(self, url, opt)
		if not opt then opt = {} end
		
		
		if not opt.bypassWaiting then self:WaitUntilReady() end
		
		game.FrameworkService:LockServer(debug.traceback(), "Get")
		if not opt.bypassConnectionLock then
			game.FrameworkService:LockConnected(debug.traceback(), "Get")
		end
		local result
		local s, e = pcall(function()
			result = self._:GetAsync(self:AppendQueryString("https://api.xeptix.com/framework/v3/"..url, self:Encode(self:QueryString({
				apikey = game:GetFrameworkModule().WebConnection.ApiKey.Value,
				gamekey = game:GetFrameworkModule().WebConnection.GameKey.Value,
				secret = game:GetFrameworkModule().WebConnection.SecretKey.Value,
				ServerId = game.FrameworkInternalService.ServerId,
				JobId = game.JobId or "0",
				PlaceId = game.PlaceId or "0",
				CreatorId = game.CreatorId or "0",
				CreatorType = tostring(game.CreatorType),
				VIPServerId = game.VIPServerId or 0,
				VIPServerOwnerId = game.VIPServerOwnerId or 0,
				FRV = game.FrameworkService.Version,
				FRB = game.FrameworkService.Build
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
		if not opt then opt = {} end
		
		if not opt.bypassWaiting then self:WaitUntilReady() end
		
		game.FrameworkService:LockServer(debug.traceback(), "Post")
		if not opt.bypassConnectionLock then
			game.FrameworkService:LockConnected(debug.traceback(), "Post")
		end
		
		
		local result
		local s, e = pcall(function()
			result = self._:PostAsync(self:AppendQueryString("https://api.xeptix.com/framework/v3/"..url, self:Encode(self:QueryString({
				apikey = game:GetFrameworkModule().WebConnection.ApiKey.Value,
				gamekey = game:GetFrameworkModule().WebConnection.GameKey.Value,
				secret = game:GetFrameworkModule().WebConnection.SecretKey.Value,
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
	end,--
	Decode = function(self, url)
		game.FrameworkService:LockServer(debug.traceback(), "Decode")
		game.FrameworkService:LockConnected(debug.traceback(), "Decode")
		
		game.FrameworkService:CheckArgument(debug.traceback(), "Decode", 1, url, "string")
		return self._:UrlDecode(url)
	end,
	payload = {players = {}, sales = {}, visits = {}, errors = {}},
	ce = {},--
	GetPayload = function(self)
		self.payload.time = os.time()
		return self.payload
	end,
	ClearPayload = function(self)
		self.payload.sales = {}
		self.payload.visits = {}
		self.payload.errors = {}
	end
}}--