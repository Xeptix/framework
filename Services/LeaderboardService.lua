-- Leaderboards

return {"LeaderboardService", "LeaderboardService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l
		
		self:SetEvent("OnUpdate")
		
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	cache = {},
	pending = {},
	FetchLeaderboard = function(self, opt)
		game.FrameworkService:CheckArgument(debug.traceback(), "FetchLeaderboard", 1, opt,"table")
		
		if game:Is("Client") then
			local leaderboard = game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("LeaderboardService", "FetchLeaderboard", opt)
			local didConnect
			local signal = game:CreateSignal()
			leaderboard.Updated = setmetatable({}, {__index = function(self, key)
				--print("INDEXED:",key)
				if key:lower() == "connect" then
					--print("CONNECTED SIGNAL!")
					if not didConnect then
						didConnect = true
						game.LeaderboardService.OnUpdate:connect(function(id)
							if id == leaderboard.id then
								signal:fire(game.LeaderboardService.cache[leaderboard.id])
							end
						end)
					end
				end
				
				return function(self, ...)
					if key:lower() == "connect" then
						return signal:connect(...)
					elseif key:lower() == "disconnect" then
						return signal:disconnect(...)
					elseif key:lower() == "fire" then
						return signal:fire(...)
					elseif key:lower() == "wait" then
						return signal:wait(...)
					end
				end
			end})
			
			function leaderboard:GetPlayerRank(player)
				return game.LeaderboardService:GetPlayerRank(player, leaderboard)
			end
			
			self.cache[leaderboard.id] = leaderboard
			return self.cache[leaderboard.id]
		end
		
		game.FrameworkService:LockConnected(debug.traceback(), "FetcnLeaderboard")
		
		if not opt then opt = {} end
		local Correct = {"Key", "Start", "Limit", "Direction", "Op", "Query", "Value", "Sort", "ID"}
		for _,v in pairs(Correct) do
			if opt[v:lower()] ~= nil then
				opt[v] = opt[v:lower()]
			end
		end
		--print("KEY:", opt.Key)
		opt.Key = tostring(opt.Key) or ""
		opt.Start = tonumber(opt.Start) or 0
		opt.Limit = tonumber(opt.Limit) or 100
		if opt.Limit > 1000 then opt.Limit = 1000 end
		if not opt.Direction then opt.Direction = "DESC" end
		opt.Direction = tostring(opt.Direction) or "DESC"
		opt.Direction = opt.Direction:lower()
		opt.Op = opt.Op or "="
		--if opt.Direction ~= "DESC" and opt.Direction ~= "ASC" then opt.Direction = "DESC" end
		if opt.Op == "=>" then opt.Op = ">=" end
		if opt.Op == "=<" then opt.Op = "<=" end
		if opt.Op and opt.Op ~= "=" and opt.Op ~= "<" and opt.Op ~= ">" and opt.Op ~= "<=" and opt.Op ~= ">=" then opt.Op = "=" end
		opt.Query = opt.Query or ""
		if opt.Value and opt.Value ~= "" then
			opt.Value = tostring(opt.Value) or ""
			local num = tostring(opt.Value:match('%f[%d]%d[,.%d]*%f[%D]'))
			local x = opt.Value:gsub(num, "")
			if #x > 0 then opt.Op = x end
			opt.Value = tostring(num)
			if opt.Op == "=>" then opt.Op = ">=" end
			if opt.Op == "=<" then opt.Op = "<=" end
			if opt.Op and opt.Op ~= "=" and opt.Op ~= "<" and opt.Op ~= ">" and opt.Op ~= "<=" and opt.Op ~= ">=" then opt.Op = "=" end
		else opt.Value = "" end
		opt.Sort = tostring(opt.Sort) or ""
		
		local leaderboard = {}
		local _t = tick()
		game.FrameworkInternalService:LoadSha1()
		--print("SHA-1 LOAD",tick()-_t)
		_t = tick()
		if opt.id then
			leaderboard.id = opt.id
		elseif opt.ID then
			leaderboard.id = opt.ID
		else
			leaderboard.id = game.FrameworkInternalService:LoadSha1().sha1("Leaderboard-" .. opt.Key .. "-" .. opt.Start .. "-" .. opt.Limit .. "-" .. opt.Direction .. "-" .. opt.Op .. "-" .. opt.Value .. "-" .. opt.Sort .. "-" .. opt.Query ..  ":" .. game:GetFrameworkModule().WebConnection.GameKey.Value)
		end
		--print("SHA-1 OP",tick()-_t)
		leaderboard.ID = leaderboard.id
		
		opt.ID = leaderboard.id
		for _,v in pairs(opt) do
			if _:lower() ~= _ then
				opt[_:lower()] = v
				opt[_] = nil
			end
		end
		leaderboard.opt = opt
		
		if self.cache[leaderboard.id] then
			return self.cache[leaderboard.id]
		end
		
		if self.pending[leaderboard.id] then
			wait(1)
			return self:FetchLeaderboard(opt)
		end
		
		self.pending[leaderboard.id] = true
		local result = game.FrameworkHttpService:Post("leaderboard_get", opt, {json = true})
		local data
		if result and not result.success and result.error == 404 then
			data = {}
		elseif not result or not result.success then
			game.FrameworkService:DebugOutput("LeaderboardService fetch request failed, trying again in " .. game.FrameworkHttpService.FailedRequestRepeatDelay .. " second(s)")
			wait(game.FrameworkHttpService.FailedRequestRepeatDelay)
			
			self.pending[leaderboard.id] = nil
			return self:FetchLeaderboard(opt)
		else
			data = result.list
		end
		
		leaderboard.list = data
		leaderboard.List = data
		leaderboard.rankCache = {}
		
		function leaderboard:GetPlayerRank(player) -- can be multiple players
			game.FrameworkService:CheckArgument(debug.traceback(), "GetPlayerRank", 1, player,{"number", "table", "Instance"})
			
			local ids = {}
			if typeof(player) == "Instance" and player:IsA("Player") then table.insert(ids, player.userId) end
			if typeof(player) == "number" then table.insert(ids, player) end
			if typeof(player) == "table" then
				for _,v in pairs(player) do
					if typeof(v) == "number" then
						table.insert(ids, v)
					elseif typeof(v) == "Instance" and v:IsA("Player") then
						table.insert(ids, v.userId)
					end
				end
				
				local list = {}
				if #ids >= 1 then
					for i = 1, #ids do
						local id = ids[i]
						list[i] = self:GetPlayerRank(id)
					end
				end
				return unpack(list)
			end
			
			if #ids <= 0 then return 0 end
			if self.rankCache[tostring(ids)] then return self.rankCache[tostring(ids)] end
		
			self.opt.player = player
			local result = game.FrameworkHttpService:Post("leaderboard_rank", self.opt, {json = true})
			local rank
			if result and not result.success and result.error == 404 then
				rank = result.MaxRank
			elseif not result or not result.success then
				game.FrameworkService:DebugOutput("LeaderboardService getPlayerRank request failed!")
				return
			else
				rank = result.rank
			end
			
			self.rankCache[tostring(ids)] = rank
			return rank
		end
		
		local didConnect
		local signal = game:CreateSignal()
		leaderboard.Updated = setmetatable({}, {__index = function(self, key)
			--print("INDEXED:",key)
			if key:lower() == "connect" then
				--print("CONNECTED SIGNAL!")
				if not didConnect then
					didConnect = true
					game.LeaderboardService.OnUpdate:connect(function(id)
						if id == leaderboard.id then
							signal:fire(game.LeaderboardService.cache[leaderboard.id])
						end
					end)
				end
			end
			
			return function(self, ...)
				if key:lower() == "connect" then
					return signal:connect(...)
				elseif key:lower() == "disconnect" then
					return signal:disconnect(...)
				elseif key:lower() == "fire" then
					return signal:fire(...)
				elseif key:lower() == "wait" then
					return signal:wait(...)
				end
			end
		end})
		
		
		leaderboard.t = os.time() + 300
		game.ThreadService:Thread(function()
			if os.time() <= leaderboard.t then return end
			
			-- update the leaderboard
			local result = game.FrameworkHttpService:Post("leaderboard_get", leaderboard.opt, {json = true})
			local data
			if result and not result.success and result.error == 404 then
				data = {}
			elseif not result or not result.success then
				game.FrameworkService:DebugOutput("LeaderboardService update request failed!")
				return
			else
				data = result.list
			end
			
			self.cache[leaderboard.id].list = data
			self.cache[leaderboard.id].List = data
			self.cache[leaderboard.id].rankCache = {}
			
			game.LeaderboardService.OnUpdate:fire(leaderboard.id)
			game:GetFrameworkModule().ClientLeaderboardUpdateTrigger:FireAllClients(leaderboard.id)
		end, {delay = 60*30, yield = false})
		
		self.cache[leaderboard.id] = leaderboard
		self.pending[leaderboard.id] = nil
		return self.cache[leaderboard.id]
	end,
	GetPlayerRank = function(self, player, leaderboard) -- pass in the leaderboard obj from above
		if game:Is("Client") then
			return game:GetFrameworkModule().ClientToServerRedirection:InvokeServer("LeaderboardService", "GetPlayerRank", player, leaderboard)
		end
		
		game.FrameworkService:LockConnected(debug.traceback(), "GetPlayerRank")
		
		if not leaderboard.GetPlayerRank and leaderboard.opt then
			--leaderboard.opt.id = leaderboard.id
			return self:FetchLeaderboard(leaderboard.opt):GetPlayerRank(player)
		end
		
		return leaderboard:GetPlayerRank(player)
	end
}}