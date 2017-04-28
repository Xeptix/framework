-- For storing and fetching serialized data to/from the webserver.


return {"StorageService", "StorageService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		if game:Is("Server") then 
			game.ThreadService:Thread(function()
				for _,v in pairs(game.StorageService.storage) do
					if v[1] + 300 <= os.time() then
						game.StorageService.storage[_] = nil
					end--
				end
	
				game.StorageService.Requests = game.StorageService.Requests + 25
				if game.StorageService.Requests >= 100 then game.StorageService.Requests = 100 end
			end, 60, true)
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Requests = 100,
	storage = {},
	Get = function(self, Key, NoCache)
		game.FrameworkService:LockServer(debug.traceback(), "Get")
		game.FrameworkService:LockConnected(debug.traceback(), "Get")
		
		local Key = tostring(Key)
		if self.storage[Key] and not NoCache then
			self.storage[Key][1] = os.time()
			return self.storage[Key][2]
		end
		
		if self.Requests <= 0 then repeat wait() until self.Requests >= 1 end self.Requests = self.Requests - 1
		
		local data = game.FrameworkHttpService:Post("storage_get", {Key = Key}, {json = true})
		if not data then wait(30) return self:Get(Key) end
		
		if data._____serialized then
			data = game.FrameworkService:Unserialize(data)
		elseif data.error then
			data = nil
		end
		
		self.storage[Key] = {os.time(), data}
		
		return data
	end,
	Set = function(self, Key, Value)
		if self.Requests <= 0 then repeat wait() until self.Requests >= 1 end self.Requests = self.Requests - 1
		
		game.FrameworkService:LockServer(debug.traceback(), "Set")
		game.FrameworkService:LockConnected(debug.traceback(), "Set")
		
		if self.storage[tostring(Key)] then
			self.storage[tostring(Key)][1] = os.time()
			self.storage[tostring(Key)][2] = Value
		else
			self.storage[tostring(Key)] = {os.time(), Value}
		end
		
		local oValue = Value
		local Key, Value = tostring(Key), game.FrameworkService:Serialize(Value, true)
		local result = game.FrameworkHttpService:Post("storage_set", {Key = Key, Value = Value}, {json = true})
		
		if not result or not result.success then
			wait(30)
			
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
					self.Requests = self.Requests + 1
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					self:Set(v, f(self:Get(v)))
				end
			elseif typeof(UpdateFunctions) == "function" then
				for _,v in pairs(Keys) do
					self.Requests = self.Requests + 1
					local f = UpdateFunctions
					self:Set(v, f(self:Get(v)))
				end
			end
		else
			if typeof(UpdateFunctions) == "table" then
				self.Requests = self.Requests + 1
				local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
				self:Set(Keys, f(self:Get(Keys)))
			elseif typeof(UpdateFunctions) == "function" then
				self.Requests = self.Requests + 1
				local f = UpdateFunctions
				self:Set(Keys, f(self:Get(Keys)))
			end
		end
	end
}}