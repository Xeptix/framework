-- For storing and fetching numerical increments to/from the webserver.


local Requests = 100
local cache = {}
local PendingOperations = {}
local RepeatedFails = 0
local CounterDS
return {"CounterService", "CounterService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		if game:Is("Server") then
			pcall(function()
				CounterDS = game:GetService("DataStoreService"):GetDataStore("XeptixFramework_Counters")
			end)
			
			game.ThreadService:Thread(function()
				for _,v in pairs(cache) do
					if v[1] + game.FrameworkHttpService.CachedItemExpieryTime <= os.time() then
						cache[_] = nil
					end--
				end
				
				local AreOperationsPending = false
				for _,v in pairs(PendingOperations) do AreOperationsPending = true break end
				
				if AreOperationsPending then
					local result
					spawn(function() result = game.FrameworkHttpService:Post("counter_sync", PendingOperations, {json = true}) end)
					local et = tick() + 5
					while et > tick() and not result do wait() end
					
					if CounterDS then
						local t = os.time()
						local s, e = pcall(function()
							CounterDS:UpdateAsync("Counters", function(old)
								if not old then
									local new = {os.time(), {}, (result and result.success) and os.time() or 0}
									for i,v in pairs(PendingOperations) do
										for _,vv in pairs(v) do
											if vv[1] == 'set' or vv[1] == 'add' then
												new[2][i] = vv[2]
											else
												new[2][i] = -vv[2]
											end
										end
									end
									
									
									return new
								end
								
								for i,v in pairs(PendingOperations) do
									for ii = 1,#v do
										local vv = v[ii]
										if vv then
											if vv[1] == 'set' then
												old[2][i] = vv[2]
											elseif vv[1] == 'add' then
												old[2][i] = old[2][i] + vv[2]
											else
												old[2][i] = old[2][i] - vv[2]
											end
										end
									end
								end
								
								
								old[1] = t
								
								if result and result.success then
									old[3] = t
								end
								
								return old
							end)
						end)
						
						if (not result or not result.success) and s then
							result = {success = true}
						end
					end
					
					
					if result and result.success then
						PendingOperations = {}
						RepeatedFails = 0
					else
						RepeatedFails = RepeatedFails + 1
						if RepeatedFails >= 15 then
							game.FrameworkService:DebugOutput("Couldn't contact webserver for 15 attempts, destroying pending counter data.")
							PendingOperations = {} -- We don't want to clutter the memory with pending opps when the website is down.
						end
					end
				end
	
				Requests = math.ceil(Requests + (game.FrameworkHttpService.CounterServicePerMin / 4))
				if Requests >= game.FrameworkHttpService.CounterServiceCap then Requests = game.FrameworkHttpService.CounterServiceCap end
			end, {delay = 15, yield = true, onclose = true})
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Get = function(self, Key, NoCache)
		game.FrameworkService:LockServer(debug.traceback(), "Get")
		game.FrameworkService:LockConnected(debug.traceback(), "Get")
		
		local Key = tostring(Key)
		if cache[Key] and not NoCache and (Requests <= 0 or cache[Key][1] + game.FrameworkHttpService.CounterServiceRefetch >= os.time()) then
			--cache[Key][1] = os.time()
			return cache[Key][2]
		end
		
		if Requests <= 0 then repeat wait() until Requests >= 1 end Requests = Requests - 1
		
		local result
		spawn(function() result = game.FrameworkHttpService:Post("counter_get", {Key = Key}, {json = true}) end)
		local et = tick() + 5
		while et > tick() and not result do wait() end
		
		local data
		local data2
		local d2t
		local d2t2
		if CounterDS then
			pcall(function()
				local meh = CounterDS:GetAsync("Counters")
				
				if meh then
					d2t = meh[1]
					d2t2 = meh[3]
					data2 = meh[2][Key]
				end
			end)
		end
		
		if result and not result.success and result.error == 404 then
			data = 0
		elseif (not result or not result.success) and not CounterDS then
			wait(game.FrameworkHttpService.FailedRequestRepeatDelay)
			
			return self:Get(Key, NoCache)
		else
			data = result.value
		end
		
		if (result and result.success) or data2 then
			if (result and result.success) and not data2 then
				-- nothing
			elseif data2 and not (result and result.success) then
				data = data2
				self:Set(Key, data)
			elseif data2 and (result and result.success) and d2t2 and d2t then
				if d2t2 < d2t then
					data = data2
					self:Set(Key, data)
				end
			end
		else
			wait(game.FrameworkHttpService.FailedRequestRepeatDelay)
			
			return self:Get(Key, NoCache)
		end
		
		data = tonumber(data) or 0
		
		cache[Key] = {os.time(), data}
		
		return data
	end,
	Set = function(self, Key, Value)
		game.FrameworkService:CheckArgument(debug.traceback(), "Set", 2, Value, "number")--
		
		game.FrameworkService:LockServer(debug.traceback(), "Set")
		game.FrameworkService:LockConnected(debug.traceback(), "Set")
		
		local Key = tostring(Key)
		if cache[Key] then
			--cache[Key][1] = os.time()
			cache[Key][2] = Value
		else
			cache[Key] = {os.time(), Value}
		end
		
		if not PendingOperations[Key] then
			PendingOperations[Key] = {}
		end
		
		table.insert(PendingOperations[Key], {"set", Value})
		
		return Value
	end,
	Update = function(self, Keys, UpdateFunctions) --todo: in documentation note that this may overwrite some changes made in other servers, similar to Set, unlike Add/Sub
		game.FrameworkService:LockServer(debug.traceback(), "Update")
		game.FrameworkService:LockConnected(debug.traceback(), "Update")
		
		if typeof(Keys) == "table" then
			if typeof(UpdateFunctions) == "table" then
				for _,v in pairs(Keys) do
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					self:Set(v, f(self:Get(v, true)))
				end
			elseif typeof(UpdateFunctions) == "function" then
				for _,v in pairs(Keys) do
					local f = UpdateFunctions
					self:Set(v, f(self:Get(v, true)))
				end
			end
		else
			if typeof(UpdateFunctions) == "table" then
				local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
				self:Set(Keys, f(self:Get(Keys, true)))
			elseif typeof(UpdateFunctions) == "function" then
				local f = UpdateFunctions
				self:Set(Keys, f(self:Get(Keys, true)))
			end
		end
	end,
	Add = function(self, Key, Num)
		game.FrameworkService:CheckArgument(debug.traceback(), "Add", 2, Num, {"number", "nil"})
		
		if not Num then Num = 1 end
		
		game.FrameworkService:LockServer(debug.traceback(), "Add")
		game.FrameworkService:LockConnected(debug.traceback(), "Add")
		
		local Key = tostring(Key)
		if cache[Key] then
			--cache[Key][1] = os.time()
			cache[Key][2] = cache[Key][2] + Num
		end
		
		if not PendingOperations[Key] then
			PendingOperations[Key] = {}
		end
		
		table.insert(PendingOperations[Key], {"add", Num})
	end,
	Subtract = function(self, Key, Num)
		game.FrameworkService:CheckArgument(debug.traceback(), "Subtract", 2, Num, {"number", "nil"})
		
		if not Num then Num = 1 end
		
		game.FrameworkService:LockServer(debug.traceback(), "Subtract")
		game.FrameworkService:LockConnected(debug.traceback(), "Subtract")
		
		local Key = tostring(Key)
		if cache[Key] then
			--cache[Key][1] = os.time()
			cache[Key][2] = cache[Key][2] - Num
		end
		
		if not PendingOperations[Key] then
			PendingOperations[Key] = {}
		end
		
		table.insert(PendingOperations[Key], {"subtract", Num})
	end,
	Sub = function(self, Key, Num)
		game.FrameworkService:CheckArgument(debug.traceback(), "Sub", 2, Num, {"number", "nil"})
		
		return self:Subtract(Key, Num)
	end
}}