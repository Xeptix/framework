-- An internal service which handles player's data.

return {"PlayerDataService", "PlayerDataService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		if game:Is("Server") then
			Databases = {}
			Databases[1] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData")
			Databases[2] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData2")
			Databases[3] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData3")
			Databases[4] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData4")
			Databases[5] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData5")
		end
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	storage = {},
	locked = {},
	LoadData = function(self, player, profile)
		game.FrameworkService:CheckArgument(debug.traceback(), "LoadData", 1, player, {"number","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "LoadData", 2, profile, {"number","nil"})
		
		if profile < 1 or profile > 5 then ferror(debug.traceback(), "Profile must be a number from 1 to 5") end
		
		if not profile then profile = 1 end
		
		local id = player
		if typeof(player) == "Instance" and not player:IsA("Player") then
			id = player.userId
			return
		end
		
		local strid = id .. "-" .. profile
		if self.locked[strid] then
			return self:WaitForData(player, profile)
		elseif self.storage[strid] then
			return self.storage[strid]
		end
		
		self.locked[strid] = true
		
		local data
		if id >= 1 then
			data = game.FrameworkHttpService:Post("playerdata_get", {UserID = id, Profile = profile}, {json = true})
			local success
			if data and type(data) == "table" then
				if data.success == false and data.error == 404 and data.message then
					-- couldn't find their data in the database
				else
					success = true
				end
			end
			
			local data2
			pcall(function()
				data2 = Databases[profile]:GetAsync("PlayerList$" .. id)
			end)
			
			if not success and data2 then
				data = data2
			else
				if data2 and data2.lastSave and data.lastSave and data.lastSave < data2.lastSave then
					data = data2
				end
			end
		else
			data = {}
		end
		
		if data._____serialized then
			data = game.FrameworkService:Unserialize(data)
		end
		
		if not data.player or not data.internal then
			data = {player = data or {}, internal = {created = os.time()}, lastSave = 0}
		end
		
		for _,v in pairs(data.player) do
			if _:sub(1,#"XeptixFramework/") == "XeptixFramework/" then
				data.internal[_:sub(#"XeptixFramework/"+1)] = v
				data.player[_] = nil
			elseif _:sub(1,#"XeptixFramework_") == "XeptixFramework_" then
				data.internal[_:sub(#"XeptixFramework_"+1)] = v
				data.player[_] = nil
			end
		end
		
		self.storage[strid] = {}
		self.storage[strid].data = data.player
		self.storage[strid].idata = data.internal
		self.storage[strid].touched = {}
		self.storage[strid].itouched = {}
		self.storage[strid].lastTouch = os.time()
		self.storage[strid].lastSave = os.time()
		self.storage[strid].AutoSave = true
		self.storage[strid].Changed = LoadLibrary("RbxUtility"):CreateSignal()
		self.storage[strid].iChanged = LoadLibrary("RbxUtility"):CreateSignal()
		
		local function touch(_, i)
			if _ and not i then
				self.storage[strid].touched[_] = os.time()
			elseif _ and i then
				self.storage[strid].itouched[_] = os.time()
			end
			self.storage[strid].lastTouch = os.time()
		end
		
		function self.storage[strid]:Get(Key)
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):Get(Key)
			end
			
			touch(Key)
			return self.storage[strid].data[Key]
		end
		
		function self.storage[strid]:Set(Key, Value)
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):Set(Key, Value)
			end
			
			local old = self.storage[strid].data[Key]
			if old == Value then return end
			
			self.storage[strid].data[Key] = Value
			touch(Key)
			self.storage[strid].Changed:fire(Key, Value, old)
		end
		
		function self.storage[strid]:iGet(Key)
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):iGet(Key)
			end
			
			touch(Key, true)
			return self.storage[strid].idata[Key]
		end
		
		function self.storage[strid]:iSet(Key, Value)
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):iSet(Key, Value)
			end
			
			local old = self.storage[strid].idata[Key]
			if old == Value then return end
			
			self.storage[strid].idata[Key] = Value
			touch(Key, true)
			self.storage[strid].iChanged:fire(Key, Value, old)
		end
		
		function self.storage[strid]:Delete()
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):Delete()
			end
			
			for _,v in pairs(self.storage[strid].data) do
				self.storage[strid].Changed:fire(_, nil, v)
				touch(_)
			end
			
			self.storage[strid].data = {}
		end
		
		function self.storage[strid]:Save()
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):Save()
			end
			
			if self.storage[strid].lastSave > self.storage[strid].lastTouch or id <= 0 then return end
			
			self.storage[strid].lastSave = os.time()
			local u = self.storage[strid]:iGet("username") or ("Player#" .. id)
			local d = game.FrameworkService:Serialize({player = self.storage[strid].data, internal = self.storage[strid].idata, lastTouch = self.storage[strid].lastTouch, lastSave = self.storage[strid].lastSave})
			
			game.FrameworkHttpService:Post("playerdata_set", {UserID = id, Profile = profile, Data = d, Username = u, PlayerInfo = self.storage[strid]:iGet("PlayerInfo") or {}}, {json = true})
			Databases[profile]:SetAsync("PlayerList$" .. id, d)
		end
		
		function self.storage[strid]:Update(Keys, UpdateFunctions)
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):Update(Keys, UpdateFunctions)
			end
			
			if typeof(Keys) == "table" then
				if typeof(UpdateFunctions) == "table" then
					for _,v in pairs(Keys) do
						local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
						Save:Set(v, f(Save:Get(v)))
					end
				elseif typeof(UpdateFunctions) == "function" then
					for _,v in pairs(Keys) do
						local f = UpdateFunctions
						Save:Set(v, f(Save:Get(v)))
					end
				end
			else
				if typeof(UpdateFunctions) == "table" then
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					Save:Set(Keys, f(Save:Get(Keys)))
				elseif typeof(UpdateFunctions) == "function" then
					local f = UpdateFunctions
					Save:Set(Keys, f(Save:Get(Keys)))
				end
			end
		end
		
		function self.storage[strid]:GetKeys()
			if not self.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return self:LoadData(id, profile):GetKeys()
			end
			
			local Keys = {}
			for _,v in pairs(self.storage[strid].data) do
				table.insert(Keys, _)
			end
			
			return Keys
		end
		
		self.locked[strid] = false
		return self.storage[strid]
	end,
	UnloadData = function(self, player, profile)
	
	end
	SaveData = function(self, player, profile)
	
	end,
	DeleteData = function(self, player, profile)
	
	end,
	CopyData = function(self, player, profile1, profile2)
	
	end,
	WaitForData = function(self, player, profile)
	
	end,
}}