-- Matchmaking


local cache = {}
local allowRetry = true
local ReserveCode = nil
return {"MatchmakingService", "MatchmakingService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l, m, n)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require, ferror, tostring = a, b, c, d, e, f, g, h, i, j, k, l, m, n

		TeleportService = game:GetService("TeleportService")
		
		if game:Is("Server") then 
			game.ThreadService:Thread(function()
				for _,v in pairs(cache) do
					if v[1] + game.FrameworkHttpService.CachedItemExpieryTime <= os.time() then
						cache[_] = nil
					end--
				end
			end, {delay = 15, yield = true})
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	DisableRetry = function(self)
		allowRetry = false
	end,
	GetParam = function(self, Param, NoCache)
		--print("??")
		if game:Is("Client") then
			local param = game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("MatchmakingService", "GetParam", Param)
			return param
		end
		
		game.FrameworkService:LockConnected(debug.traceback(), "GetParam")
		--print("?? 2")
		for _,v in pairs(game.FrameworkHttpService.payload.params) do
			if v and v[1] == Param then
				--print("A")
				return v[2]
			end
		end
		--print("?? 3")
		
		Param = tostring(Param):gsub(" ", ""):gsub("\n",""):gsub("\t","")
		
		local Key = tostring(Param):lower()
		if cache[Key] and not NoCache and (cache[Key][1] + game.FrameworkHttpService.ParamCache >= os.time()) then
			--cache[Key][1] = os.time()
			--print("B")
			return cache[Key][2]
		end
		--print("?? 4")
		
		local result = game.FrameworkHttpService:Post("matchmaking_param", {Key = Key}, {json = true})
		local data
		--print("?? 5")
		if result and not result.success and result.error == 404 then
			data = nil
		elseif not result or not result.success then
			wait(game.FrameworkHttpService.FailedRequestRepeatDelay)
			
			--print("C")
			return self:GetParam(Key, NoCache)
		else
			data = result.value
		end
		
		data = data
		
		cache[Key] = {os.time(), data}
		
		--print("D", data, result.value)
		return data
	end,
	SetParam = function(self, Param, Value)
		game.FrameworkService:LockServer(debug.traceback(), "SetParam")
		game.FrameworkService:LockConnected(debug.traceback(), "SetParam")
		
		if type(Value) ~= "number" and type(Value) ~= "string" and Value ~= nil then
			Value = tostring(Value)
		end
		
		Param = tostring(Param):gsub(" ", ""):gsub("\n",""):gsub("\t","")
		
		local set = false
		for _,v in pairs(game.FrameworkHttpService.payload.params) do
			if v and v[1] == Param then
				game.FrameworkHttpService.payload.params[_][2] = Value
				set = true
			end
		end
		
		if not set then
			table.insert(game.FrameworkHttpService.payload.params, {Param, Value})
		end
		
		if cache[tostring(Param):lower()] then
			cache[tostring(Param):lower()][2] = Value
		end
	end,
	UpdateParam = function(self, Keys, UpdateFunctions)
		game.FrameworkService:LockServer(debug.traceback(), "UpdateParam")
		game.FrameworkService:LockConnected(debug.traceback(), "UpdateParam")
		
		if typeof(Keys) == "table" then
			if typeof(UpdateFunctions) == "table" then
				for _,v in pairs(Keys) do
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					self:Set(v, f(self:Get(v)))
				end
			elseif typeof(UpdateFunctions) == "function" then
				for _,v in pairs(Keys) do
					local f = UpdateFunctions
					self:Set(v, f(self:Get(v)))
				end
			end
		else
			if typeof(UpdateFunctions) == "table" then
				local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
				self:Set(Keys, f(self:Get(Keys)))
			elseif typeof(UpdateFunctions) == "function" then
				local f = UpdateFunctions
				self:Set(Keys, f(self:Get(Keys)))
			end
		end
	end,
	LocalJoin = function(self, PlaceID, JobID, ReserveCode, Player, Gui)
		if Gui == "nil" then Gui = nil elseif typeof(Gui) == "string" and game.StarterGui:FindFirstChild(tostring(Gui)) then Gui = game.StarterGui:findFirstChild(tostring(Gui)) elseif typeof(Gui) == "string" then Gui = nil end
		
		local s, e = pcall(function()
			if JobID == game.JobId then return true end
			
			if ReserveCode then
				--print(PlaceID, ReserveCode, {Player}, "", {___RsrvCode = ReserveCode}, Gui)
				return TeleportService:TeleportToPrivateServer(PlaceID, ReserveCode, {Player}, "", {___RsrvCode = ReserveCode}, Gui) -- nil = gui
			end
			
			TeleportService:TeleportToPlaceInstance(PlaceID, JobID, Player)
		end)
		
		--print(s,e)
		
		if s then
			return {true}
		else
			return {false, e}
		end
	end,
	FetchServers = function(self, PlaceID, Sort, Params)
		--game.FrameworkService:LockServer(debug.traceback(), "FetchServers")
		game.FrameworkService:LockConnected(debug.traceback(), "FetchServers")
		
		if game:Is("Client") then
			local servers = game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("MatchmakingService", "FetchServers", PlaceID, Sort, Params)
			--print("Huh?", #servers)
			for i,v in pairs(servers) do
				servers[i].Teleport = function(self, Gui)
					local pid, jid, rc = self.PlaceID, self.JobID, self.ReserveCode
					local r = game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("MatchmakingService", "LocalJoin", pid, jid, rc, game.Players.LocalPlayer, tostring(Gui))
					
					return unpack(r)
				end
				
				servers[i].Join = function(self, Queue)
					return self:Teleport(Queue)
				end
			end
			return servers
		end
		
		if typeof(PlaceID) == "number" then
			PlaceID = {PlaceID}
		elseif typeof(PlaceID) ~= "table" then
			PlaceID = {tonumber(PlaceID) or game.PlaceId}
		end
		
		Sort = Sort or {}
		Params = Params or {}
		
		for i,v in pairs(PlaceID) do
			PlaceID[i] = tonumber(v) or game.PlaceId
		end
		
		if Sort[1] then
			Sort[1] = tostring(Sort[1]):gsub(" ", ""):gsub("\n",""):gsub("\t",""):upper()
			if Sort[1] ~= "DESC" and Sort[1] ~= "ASC" then
				Sort[1] = "DESC"
			end
		end
		
		if Sort[2] then
			Sort[2] = tostring(Sort[2]):gsub(" ", ""):gsub("\n",""):gsub("\t",""):lower()
		end
		
		if typeof(Params[1]) == "string" then
			Params = {Params}
		end
		
		for i,v in pairs(Params) do
			Params[i][1] = tostring(v[1]):gsub(" ", ""):gsub("\n",""):gsub("\t","")
			if Params[i][2] and v[3] then
				Params[i][2] = tostring(v[2]):gsub(" ", ""):gsub("\n",""):gsub("\t","")
			end
			if v[1] and v[2] and not v[3] then
				Params[i][3] = v[2]
				Params[i][2] = "="
			end
		end
		
		local Ops = {["="] = true,["=="] = true,["~="] = true,["=~"] = true,[">"] = true,["<"] = true,[">="] = true,["<="] = true,["=>"] = true,["=<"] = true}
		for i, v in pairs(Params) do
			if v[1] then
				Params[i][1] = tostring(v[1]):lower()
			end
			
			if v[2] then
				Params[i][2] = tostring(v[2])
				
				if not Ops[tostring(v[2])] then
					Params[i][2] = "="
				end
			end
			
			if v[3] then
				if typeof(v[3]) ~= "number" and typeof(v[3]) ~= "string" and typeof(v[3]) ~= "table" then
					Params[i][3] = tostring(v[3])
				elseif typeof(v[3]) == "table" then
					for ii, vv in pairs(v[3]) do
						if typeof(vv) ~= "number" and typeof(vv) ~= "string" then
							Params[i][3][ii] = tostring(vv)
						end
					end
				end
				
				if Params[i][2] ~= "=" and Params[i][2] ~= "==" and Params[i][2] ~= "~=" and Params[i][2] ~= "=~" then
					if typeof(v[3]) == "table" then
						for ii, vv in pairs(v[3]) do
							if typeof(vv) ~= "number" then
								Params[i][3][ii] = tonumber(vv) or 0
							end
						end
					elseif typeof(v[3]) ~= "number" then
						Params[i][3] = tonumber(v[3]) or 0
					end
				end
			end
		end
		
		local CacheID = "MATCHES:"
		table.recursive(PlaceID, function(t, i, x)
			if type(x) == "table" then return end
			CacheID = CacheID .. tostring(i) .. tostring(x)
		end)
		CacheID = CacheID .. ":"
		table.recursive(Sort, function(t, i, x)
			if type(x) == "table" then return end
			CacheID = CacheID .. tostring(i) .. tostring(x)
		end)
		CacheID = CacheID .. ":"
		table.recursive(Params, function(t, i, x)
			if type(x) == "table" then return end
			CacheID = CacheID .. tostring(i) .. tostring(x)
		end)
		
		if cache[CacheID] and (cache[CacheID][1] + game.FrameworkHttpService.MatchmakingCache >= os.time()) then
			return cache[CacheID][2]
		end
		
		local result = game.FrameworkHttpService:Post("matchmaking_search", {PlaceID = PlaceID, Sort = Sort, Params = Params}, {json = true})
		local data = {}
		if result and not result.success and result.error == 404 then
			data = {}
		elseif not result or not result.success then
			if not allowRetry then return {} end
			
			game.FrameworkService:DebugOutput("MatchmakingService search request failed, trying again in " .. game.FrameworkHttpService.FailedRequestRepeatDelay .. " second(s)")
			wait(game.FrameworkHttpService.FailedRequestRepeatDelay)
			
			return self:FetchServers(PlaceID, Sort, Params)
		else
			data = result.value
		end
		
		for i = 1,#data do
			local v = data[i]
			if v then
				local x = {}
				for ii, vv in pairs(v.Players) do
					table.insert(x, {UserID = vv[1], Username = vv[2]})
				end
				data[i].Players = x
				
				x = {}
				for ii, vv in pairs(v.Params) do
					x[vv[1]] = vv[2]
				end
				data[i].Params = x
				
				data[i].Teleport = function(self, Player)
					local pid, jid, rc = self.PlaceID, self.JobID, self.ReserveCode
					local s, e = pcall(function()
						if jid == game.JobId then return true end
						
						if rc then
							return TeleportService:TeleportToPrivateServer(pid, rc, {Player}, "", {___RsrvCode = rc}, nil) -- nil = gui
						end
						
						TeleportService:TeleportToPlaceInstance(pid, jid, Player)
					end)
					
					if s then
						return true
					else
						return false, e
					end
				end
				
				data[i].Join = function(self, Player)
					return self:Teleport(Player)
				end
			end
		end
		
		--print("FOUND ",#data)
		
		cache[CacheID] = {os.time(), data}
		
		return data
	end,
	WaitForReserveCode = function(self) -- Only works in reserve servers, this waits until we figure out the reservecode ;)
		return game:GetFrameworkModule():WaitForChild("RsrvCode").Value
	end,
	MakeReservePublic = function(self, public) -- {Server Only} Only works in reserve servers, allows it to be shown/joinable in matchmaking
		game.FrameworkService:LockServer(debug.traceback(), "MakeReservePublic")
		
		local thisServerCode = self:WaitForReserveCode()
		game.FrameworkHttpService.payload._rp = 1
	end,
	SendReserveCodeToServer = function(self, code, public)
		game.FrameworkService:LockClient(debug.traceback(), "SendReserveCodeToServer")
		
		game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("MatchmakingService", "ReceiveReserveServerCode", tostring(code), public)
	end,
	ReceiveReserveServerCode = function(self, code, public)
		game.FrameworkService:LockServer(debug.traceback(), "ReceiveReserveServerCode")
		
		if ReserveCode then return end
		
		ReserveCode = code
		game.FrameworkHttpService.payload._rc = code
		
		local fm = game:GetFrameworkModule()
		local v = Instance.new("StringValue")
		v.Name = "RsrvCode"
		v.Value = code
		v.Parent = fm
		
		if public then
			self:MakeReservePublic()
		end
	end,
	CreatePublicReserveServer = function(self, Players, PlaceID, TeleportData, Gui)
		if Gui == "nil" then Gui = nil elseif typeof(Gui) == "string" and game.StarterGui:FindFirstChild(tostring(Gui)) then Gui = game.StarterGui[tostring(Gui)] elseif typeof(Gui) == "string" then Gui = nil end
		
		game.FrameworkService:CheckArgument(debug.traceback(), "CreatePublicReserveServer", 1, Players, {"table","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "CreatePublicReserveServer", 2, PlaceID, "number")
		game.FrameworkService:CheckArgument(debug.traceback(), "CreatePublicReserveServer", 3, TeleportData, {"table","nil"})
		game.FrameworkService:CheckArgument(debug.traceback(), "CreatePublicReserveServer", 4, Gui, {"Instance","nil"})
		
		if game:Is("Client") then
			return game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("MatchmakingService", "CreatePublicReserveServer", Players,PlaceID, TeleportData, tostring(Gui))
		end
		
		if typeof(Players) ~= "table" then Players = {Players} end
		
		local Code = TeleportService:ReserveServer(PlaceID)
		
		pcall(function()
			TeleportData = TeleportData or {}
			TeleportData.___RsrvCode = Code
			TeleportData.___PublicRsrv = true
			TeleportService:TeleportToPrivateServer(PlaceID, Code, Players, "", TeleportData, Gui:Clone()) -- last nil = custom screen
		end)
		
		return Code
	end,
	CreateReserveServer = function(self, Players, PlaceID,TeleportData, Gui)
		if Gui == "nil" then Gui = nil elseif typeof(Gui) == "string" and game.StarterGui:FindFirstChild(tostring(Gui)) then Gui = game.StarterGui[tostring(Gui)] elseif typeof(Gui) == "string" then Gui = nil end
		
		game.FrameworkService:CheckArgument(debug.traceback(), "CreateReserveServer", 1, Players, {"table","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "CreateReserveServer", 2, PlaceID, "number")
		game.FrameworkService:CheckArgument(debug.traceback(), "CreateReserveServer", 3, TeleportData, {"table","nil"})
		game.FrameworkService:CheckArgument(debug.traceback(), "CreateReserveServer", 4, Gui, {"Instance","nil"})
		
		if game:Is("Client") then
			return game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("MatchmakingService", "CreateReserveServer", Players,PlaceID, TeleportData, tostring(Gui))
		end
		
		if typeof(Players) ~= "table" then Players = {Players} end
		
		local Code = TeleportService:ReserveServer(PlaceID)
		
		pcall(function()
			TeleportData = TeleportData or {}
			TeleportData.___RsrvCode = Code
			TeleportService:TeleportToPrivateServer(PlaceID, Code, Players, "", TeleportData, Gui:Clone()) -- last nil = custom screen
		end)
		
		return Code
	end
}}