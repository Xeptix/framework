-- For storing and fetching serialized data to/from the webserver.


local Requests = 100
local storage = {}
return {"StorageService", "StorageService", {--
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		if game:Is("Server") then 
			game.ThreadService:Thread(function()
				for _,v in pairs(storage) do
					if v[1] + game.FrameworkHttpService.CachedItemExpieryTime <= os.time() then
						storage[_] = nil
					end--
				end
				
				Requests = Requests + game.FrameworkHttpService.StorageServicePerMin
				if Requests >= game.FrameworkHttpService.StorageServiceCap then Requests = game.FrameworkHttpService.StorageServiceCap end
			end, {delay = 60, yield = false})
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Get = function(self, Key, NoCache)
		game.FrameworkService:LockServer(debug.traceback(), "Get")
		game.FrameworkService:LockConnected(debug.traceback(), "Get")
		
		local Key = tostring(Key)
		if storage[Key] and not NoCache then
			storage[Key][1] = os.time()
			return storage[Key][2]
		end
		
		if Requests <= 0 then repeat wait() until Requests >= 1 end Requests = Requests - 1
		
		local result = game.FrameworkHttpService:Post("storage_get", {Key = Key}, {json = true})
		local data
		if result and not result.success and result.error == 404 then
			data = result
		elseif not result or not result.success then
			game.FrameworkService:DebugOutput("StorageService get request failed, trying again in " .. game.FrameworkHttpService.FailedRequestRepeatDelay .. " second(s)")
			wait(game.FrameworkHttpService.FailedRequestRepeatDelay)
			
			return self:Get(Key, NoCache)
		else
			data = result.value
		end
		
		if data._____serialized then
			data = game.FrameworkService:Unserialize(data)
		elseif data.error then
			data = nil
		end
		
		storage[Key] = {os.time(), data}
		
		return data
	end,
	Set = function(self, Key, Value)
		if Requests <= 0 then repeat wait() until Requests >= 1 end Requests = Requests - 1
		
		game.FrameworkService:LockServer(debug.traceback(), "Set")
		game.FrameworkService:LockConnected(debug.traceback(), "Set")
		
		if storage[tostring(Key)] then
			storage[tostring(Key)][1] = os.time()
			storage[tostring(Key)][2] = Value
		else
			storage[tostring(Key)] = {os.time(), Value}
		end
		
		local oValue = Value
		local Key, Value = tostring(Key), game.FrameworkService:Serialize(Value, true)
		local result = game.FrameworkHttpService:Post("storage_set", {Key = Key, Value = Value}, {json = true})
		
		if not result or not result.success then
			game.FrameworkService:DebugOutput("StorageService set request failed, trying again in " .. game.FrameworkHttpService.FailedRequestRepeatDelay .. " second(s)")
			wait(game.FrameworkHttpService.FailedRequestRepeatDelay)
			
			return self:Set(Key, oValue)
		end
		
		return oValue
	end,
	Delete = function(self, Key)
		game.FrameworkService:LockServer(debug.traceback(), "Delete")
		game.FrameworkService:LockConnected(debug.traceback(), "Delete")
		
		local Key = tostring(Key)
		self:Set(Key, nil)
	end,
	Update = function(self, Keys, UpdateFunctions)
		game.FrameworkService:LockServer(debug.traceback(), "Update")
		game.FrameworkService:LockConnected(debug.traceback(), "Update")
		
		if typeof(Keys) == "table" then
			if typeof(UpdateFunctions) == "table" then
				for _,v in pairs(Keys) do
					Requests = Requests + 1
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					self:Set(v, f(self:Get(v, true)))
				end
			elseif typeof(UpdateFunctions) == "function" then
				for _,v in pairs(Keys) do
					Requests = Requests + 1
					local f = UpdateFunctions
					self:Set(v, f(self:Get(v, true)))
				end
			end
		else
			if typeof(UpdateFunctions) == "table" then
				Requests = Requests + 1
				local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
				self:Set(Keys, f(self:Get(Keys, true)))
			elseif typeof(UpdateFunctions) == "function" then
				Requests = Requests + 1
				local f = UpdateFunctions
				self:Set(Keys, f(self:Get(Keys, true)))
			end
		end
	end
}}