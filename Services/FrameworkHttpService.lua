-- Framework's HttpService. Posts and gets with paramaters to identify the server, including api keys (which must be present)

return {"FrameworkHttpService", "FrameworkHttpService", {
	_StartService = function(self, a,b,c,d,e,f,g,h,i,j,k,l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		self:SetProperty("HttpEnabled", false)
		self:SetProperty("HttpFailedInitialization", false)
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
		self:SetProperty("MatchmakingCache", 15)
		self:SetProperty("ParamCache", 60)
		self:SetProperty("PayloadEnabled", false)
		local WebConnection = {}
		local WCF = game:GetFrameworkModule():FindFirstChild("WebConnection")
		if WCF then
			if game:Is("Server") then
				for _,v in pairs(WCF:GetChildren()) do
					WebConnection[v.Name] = v.Value
				end
			end

			pcall(function() WCF:Destroy() end)
		end

		if WebConnection.Connection then
			Instance.new("Folder", self).Name = "IsConnected"
		elseif self:FindFirstChild("IsConnected") then
			WebConnection.Connection = true
		end

		self:SetProperty("WebConnection", WebConnection)
		self:LockProperty("WebConnection", 2)

		local function lock()
			if true then return end
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
			self:LockProperty("MatchmakingCache", 2)
			self:LockProperty("ParamCache", 2)
			self:LockProperty("HttpConnected", 2)
		end

		if game:Is("Server") and self.WebConnection.Connection then
			spawn(function()
				if game:GetFrameworkModule():FindFirstChild("SID") then
					game:GetFrameworkModule().SID:Destroy()
				end

				game:SetProperty("Info", "")
				local passed, msg = pcall(function()
					for i = 1,3 do
						local x, e, c
						spawn(function() x, e = self:Get("server", {json=true, bypassConnectionLock=true, bypassWaiting=true}) c = true end)
						local tm = tick() + 3
						while not c and tm > tick() do wait() end

						if type(x) ~= "table" or not x.ServerId and i < 3 then
							wait(1)
						elseif type(x) ~= "table" or not x.ServerId and i == 3 then
							self:SetProperty("HttpFailedInitialization", true)

							return "nah"
						else
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
							self.CounterServiceRefetch = x.CounterServiceRefetch
							self.MatchmakingCache = x.MatchmakingCache
							self.ParamCache = x.ParamCache
							self.PayloadEnabled = true

							local SID = Instance.new("StringValue")
							SID.Parent = game:GetFrameworkModule()
							SID.Name = "SID"
							SID.Value = game.FrameworkInternalService.ServerId

							self:SetProperty("Ready", true)

							return true
						end
					end
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

					local SID = Instance.new("StringValue")
					SID.Parent = game:GetFrameworkModule()
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
		elseif game:Is("Local") and self.WebConnection.Connection then
			local SID = game:GetFrameworkModule():WaitForChild("SID", 5)
			if SID then
				game:SetProperty("Info", "PID=" .. game.PlaceId .. "&SID=" .. SID.Value)
				game:LockProperty("Info", 2)
				game.FrameworkInternalService:SetProperty("ServerId", game:GetFrameworkModule().SID.Value)
				game.FrameworkInternalService:LockProperty("ServerId", 2)

				self:SetProperty("Ready", true)

				self:SetProperty("HttpFailedInitialization", true)

				lock()
			else
				game:SetProperty("Info", "PID=" .. game.PlaceId)
				game:LockProperty("Info", 2)
				game.FrameworkInternalService:SetProperty("ServerId", 0)
				game.FrameworkInternalService:LockProperty("ServerId", 2)

				self:SetProperty("Ready", true)
				self:SetProperty("HttpFailedInitialization", true)

				lock()
			end
		else
			game:SetProperty("Info", "PID=" .. game.PlaceId)
			game:LockProperty("Info", 2)
			game.FrameworkInternalService:SetProperty("ServerId", 0)
			game.FrameworkInternalService:LockProperty("ServerId", 2)

			self:SetProperty("Ready", true)

			self:SetProperty("HttpFailedInitialization", true)

			lock()
		end


		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	WaitUntilReady = function(self)
		if not self.Ready then
			repeat wait() until self.Ready or self.HttpFailedInitialization
		end

		--wait()
	end,
	Get = function(self, url, opt)
		if not opt then opt = {} end


		if not opt.bypassWaiting then self:WaitUntilReady() end
		if self.HttpFailedInitialization then return game:GetService("FrameworkService"):DebugOutput("FrameworkHttpService Declined GET", url, self._:JSONEncode(opt), "~ Reason: ", "FrameworkHttpService Initialization Failure (Xeptix Framework Web Servers may be down!)") end

		game.FrameworkService:LockServer(debug.traceback(), "Get")
		if not opt.bypassConnectionLock then
			game.FrameworkService:LockConnected(debug.traceback(), "Get")
		end
		local result
		local finished, done = game:CreateSignal()
		delay(url == "server" and 3 or 5, function()
			if not done then
				finished:fire()
				done = true
			end
		end)
		local e
		spawn(function()
			local s, ee = pcall(function()
				result = self._:GetAsync(self:AppendQueryString("https://api.xeptix.com/framework/v3/"..url, self:Encode(self:QueryString({
					apikey = self.WebConnection.ApiKey,
					gamekey = self.WebConnection.GameKey,
					secret = self.WebConnection.SecretKey,
					ServerId = game.FrameworkInternalService.ServerId,
					JobId = game.JobId or "0",
					PlaceId = game.PlaceId or "0",
					CreatorId = game.CreatorId or "0",
					CreatorType = tostring(game.CreatorType),
					VIPServerId = game.VIPServerId or 0,
					VIPServerOwnerId = game.VIPServerOwnerId or 0,
					Version = game.PlaceVersion or 0,
					FRV = game.FrameworkService.Version,
					FRB = game.FrameworkService.Build
				}))), true)
			end)

			e = ee
			finished:fire()
			done = true
		end)

		finished:wait()

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
		if self.HttpFailedInitialization then return game:GetService("FrameworkService"):DebugOutput("FrameworkHttpService Declined POST", url, self._:JSONEncode(opt), self._:JSONEncode(data), "~ Reason: ", "FrameworkHttpService Initialization Failure (Xeptix Framework Web Servers may be down!)") end
		if not opt.bypassConnectionLock then
			game.FrameworkService:LockConnected(debug.traceback(), "Post")
		end



		local result
		local finished, done = game:CreateSignal()
		delay(url == "server" and 3 or 5, function()
			if not done then
				finished:fire()
				done = true
			end
		end)
		local e
		spawn(function()
			local s, ee = pcall(function()
				result = self._:PostAsync(self:AppendQueryString("https://api.xeptix.com/framework/v3/"..url, self:Encode(self:QueryString({
					apikey = self.WebConnection.ApiKey,
					gamekey = self.WebConnection.GameKey,
					secret = self.WebConnection.SecretKey,
					ServerId = game.FrameworkInternalService.ServerId,
					JobId = game.JobId or "0",
					PlaceId = game.PlaceId or "0",
					CreatorId = game.CreatorId or "0",
					CreatorType = tostring(game.CreatorType),
					VIPServerId = game.VIPServerId or 0,
					VIPServerOwnerId = game.VIPServerOwnerId or 0,
					Version = game.PlaceVersion or 0,
					FRV = game.FrameworkService.Version,
					FRB = game.FrameworkService.Build
				}))), self._:JSONEncode(data))
			end)

			e = ee
			finished:fire()
			done = true
		end)

		finished:wait()

		if result and opt.json then
			if not pcall(function()
				local _t = tick()
				result = self._:JSONDecode(result)
				--print("Decoding:",tick()-_t)
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
	payload = {players = {}, sales = {}, visits = {}, errors = {}, requests = {}, joined = {}, left = {}, ban = {}, unban = {}, ce = {}, params = {}, _rc = "", _rp = 0, _mp = game.Players.MaxPlayers},
	ce = {},--
	GetPayload = function(self)
		self.payload.time = os.time()
		return self.payload
	end,
	ClearPayload = function(self)
		self.payload.sales = {}
		self.payload.visits = {}
		self.payload.errors = {}
		self.payload.requests = {}
		self.payload.params = {}
		self.payload.joined = {}
		self.payload.left = {}
		self.payload.ban = {}
		self.payload.unban = {}
	end
}}--
