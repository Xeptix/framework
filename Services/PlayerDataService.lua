-- An internal service which handles player's data.

return {"PlayerDataService", "PlayerDataService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l
		if game:Is("Server") then
			if game:GetFrameworkModule():FindFirstChild("ClientDataReplicator") then
				game:GetFrameworkModule().ClientDataReplicator:Destroy()
			end

			local ClientDataReplicator = Instance.new("Folder", game:GetFrameworkModule())
			ClientDataReplicator.Name = "ClientDataReplicator"
			self:SetProperty("ClientDataReplicator", ClientDataReplicator)
			
			Databases = {}
			pcall(function()
				Databases[1] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData") -- for compatibility with framework v2 and v1
				Databases[2] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData2")
				Databases[3] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData3")
				Databases[4] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData4")
				Databases[5] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData5")
			end)
		
			game.ThreadService:Thread(function()
				for _,v in pairs(game.PlayerDataService.storage) do
					if v and v.lastTouch then
						if v.lastTouch + 300 <= os.time() then -- hasn't been touched in 2.5 minutes, unload it if they aren't in-game
							if not game.Players:GetPlayerByUserId(v.userid) then
								game.PlayerDataService:UnloadData(v.userid, v.profile)
							end
						end
					end
					
					if v.AutoSave and v.lastSave and v.lastSave + 120 <= os.time() then
						v:Save()
					end
				end
			end, 60, true)
			
			game:BindToClose(function()
				for _,v in pairs(game.PlayerDataService.storage) do
					v:Save()
				end
			end)
		else
			-- We are going to replicate how the server handle's data to a read-only version on the client. We'll be using values and changed event listeners for efficiency purposes.
			self:SetProperty("ClientDataReplicator", game:GetFrameworkModule():WaitForChild("ClientDataReplicator"))
			
			local function ClientDataProfile(Data)
				local strid = Data.Name
				local split = string.split(strid, "-")
				local id = tonumber(split[1])
				local profile = tonumber(split[2])
				self.storage[Data.Name] = {}
				self.storage[strid].userid = id
				self.storage[strid].profile = profile
				self.storage[strid].data = {}
				self.storage[strid].idata = {}
				self.storage[strid].touched = {}
				self.storage[strid].itouched = {} 
				self.storage[strid].lastTouch = 0
				self.storage[strid].ilastTouch = 0
				self.storage[strid].edited = {}
				self.storage[strid].iedited = {}
				self.storage[strid].lastEdit = 0
				self.storage[strid].lastSave = 0
				self.storage[strid].ilastEdit = 0
				self.storage[strid].AutoSave = nil -- we dont need this rite?
				self.storage[strid].Changed = LoadLibrary("RbxUtility"):CreateSignal()
				self.storage[strid].iChanged = LoadLibrary("RbxUtility"):CreateSignal()
				
				local function setupVal(v, internal)
					local oldv = game.FrameworkInternalService:Val2Var(v)
					v.Changed:connect(function()
						local val = game.FrameworkInternalService:Val2Var(v)
						if val == oldv then return end
						
						if internal then
							game.PlayerDataService.storage[strid].idata[v.Name] = val
							game.PlayerDataService.storage[strid].iChanged:fire(v.Name, val, game.PlayerDataService.storage[strid].idata[v.Name])
						else
							game.PlayerDataService.storage[strid].data[v.Name] = val
							game.PlayerDataService.storage[strid].Changed:fire(v.Name, val, game.PlayerDataService.storage[strid].data[v.Name])
						end
					end)
				end
				
				Data.InternalData.ChildAdded:connect(function(v)
					local old = game.PlayerDataService.storage[strid].idata[v.Name]
					game.PlayerDataService.storage[strid].idata[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v, true)
					
					if old then
						game.PlayerDataService.storage[strid].iChanged:fire(v.Name, game.PlayerDataService.storage[strid].idata[v.Name], old)
					else
						game.PlayerDataService.storage[strid].iChanged:fire(v.Name, game.PlayerDataService.storage[strid].idata[v.Name], nil)
					end
				end)
				Data.InternalData.ChildRemoved:connect(function(v)
					if game.PlayerDataService.storage[strid].idata[v.Name] ~= nil then
						game.PlayerDataService.storage[strid].iChanged:fire(v.Name, nil, game.PlayerDataService.storage[strid].idata[v.Name])
					end
					
					game.PlayerDataService.storage[strid].idata[v.Name] = nil
				end)
				
				Data.PlayerData.ChildAdded:connect(function(v)
					local old = game.PlayerDataService.storage[strid].data[v.Name]
					game.PlayerDataService.storage[strid].data[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v, true)
					
					if old then
						game.PlayerDataService.storage[strid].Changed:fire(v.Name, game.PlayerDataService.storage[strid].data[v.Name], old)
					else
						game.PlayerDataService.storage[strid].Changed:fire(v.Name, game.PlayerDataService.storage[strid].data[v.Name], nil)
					end
				end)
				Data.PlayerData.ChildRemoved:connect(function(v)
					if game.PlayerDataService.storage[strid].data[v.Name] ~= nil then
						game.PlayerDataService.storage[strid].Changed:fire(v.Name, nil, game.PlayerDataService.storage[strid].data[v.Name])
					end
					
					game.PlayerDataService.storage[strid].data[v.Name] = nil
				end)
				
				for _,v in pairs(Data.InternalData:GetChildren()) do
					self.storage[strid].idata[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v, true)
				end
				
				for _,v in pairs(Data.PlayerData:GetChildren()) do
					self.storage[strid].data[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v)
				end
				
				if game.Players:GetPlayerByUserId(id) then
					self.storage[strid].player = game.Players:GetPlayerByUserId(id)
				end
				
				local _self = self.storage[strid]
				
				function _self:Get(Key)
					if not game.PlayerDataService.storage[strid] then
						return warn("Cannot Get, save for " .. id .. " has been unloaded by the server.")
					end
					
					return game.PlayerDataService.storage[strid].data[Key]
				end
				
				function _self:iGet(Key)
					if not game.PlayerDataService.storage[strid] then
						return warn("Cannot iGet, save for " .. id .. " has been unloaded by the server.")
					end
					
					return game.PlayerDataService.storage[strid].idata[Key]
				end
				
				function _self:Set()
					game.FrameworkService:LockServer(debug.traceback(), "Set")
				end
				
				function _self:iSet()
					game.FrameworkService:LockServer(debug.traceback(), "iSet")
				end
				
				function _self:Update()
					game.FrameworkService:LockServer(debug.traceback(), "Update")
				end
				
				function _self:Save()
					game.FrameworkService:LockServer(debug.traceback(), "Save")
				end
				
				function _self:Delete()
					game.FrameworkService:LockServer(debug.traceback(), "Delete")
				end
				
				function _self:GetKeys()
					if not game.PlayerDataService.storage[strid] then
						return warn("Cannot GetKeys, save for " .. id .. " has been unloaded by the server.")
					end
					
					local Keys = {}
					for _,v in pairs(game.PlayerDataService.storage[strid].data) do
						table.insert(Keys, _)
					end
					
					return Keys
				end
				
				function _self:GetPlayer()
					if not game.PlayerDataService.storage[strid] then
						return warn("Cannot GetPlayer, save for " .. id .. " has been unloaded by the server.")
					end
					
					return game.PlayerDataService.storage[strid].player
				end
			end
			
			local Children = self.ClientDataReplicator:GetChildren()
			self.ClientDataReplicator.ChildAdded:connect(function(Child)
				ClientDataProfile(Child)
			end)
			self.ClientDataReplicator.ChildRemoved:connect(function(Child)
				pcall(function() self.storage[Child.Name].Changed:disconnect() end)
				pcall(function() self.storage[Child.Name].iChanged:disconnect() end)
				self.storage[Child.Name] = nil
			end)
			
			for _,v in pairs(Children) do
				ClientDataProfile(v)
			end
		end
		
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	storage = {},
	locked = {},
	LoadData = function(self, player, profile, nocache)
		game.FrameworkService:CheckArgument(debug.traceback(), "LoadData", 1, player, {"number","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "LoadData", 2, profile, {"number","nil"})
		
		game.FrameworkService:LockServer(debug.traceback(), "LoadData")
		
		if profile and (profile < 1 or profile > 5) then error("Profile must be a number from 1 to 5") end
		
		if not profile then profile = 1 end
		
		local id = player
		if typeof(player) == "Instance" and not player:IsA("Player") then
			return
		elseif typeof(player) == "Instance" then
			id = player.userId
		end
		
		local strid = id .. "-" .. profile
		if self.locked[strid] then
			return self:WaitForData(player, profile)
		elseif self.storage[strid] and not nocache then
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
					data = {}
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
		self.storage[strid].userid = id
		self.storage[strid].profile = profile
		self.storage[strid].data = data.player
		self.storage[strid].idata = data.internal
		self.storage[strid].touched = {}
		self.storage[strid].itouched = {} 
		self.storage[strid].lastTouch = data.lastTouch or os.time()
		self.storage[strid].ilastTouch = data.lastTouch or os.time()
		self.storage[strid].edited = {}
		self.storage[strid].iedited = {}
		self.storage[strid].lastEdit = data.lastTouch or os.time()
		self.storage[strid].lastSave = data.lastSave or os.time()
		self.storage[strid].ilastEdit = data.lastTouch or os.time()
		self.storage[strid].AutoSave = true
		self.storage[strid].Changed = LoadLibrary("RbxUtility"):CreateSignal()
		self.storage[strid].iChanged = LoadLibrary("RbxUtility"):CreateSignal()
		
		local ClientDataProfile = Instance.new("Folder")
		ClientDataProfile.Name = strid
		local PlayerData = Instance.new("Folder", ClientDataProfile)
		PlayerData.Name = "PlayerData"
		local InternalData = Instance.new("Folder", ClientDataProfile)
		InternalData.Name = "InternalData"
		
		for i,v in pairs(self.storage[strid].data) do
			local x = game.FrameworkInternalService:Var2Val(v)
			x.Name = i
			x.Parent = PlayerData
		end
		
		for i,v in pairs(self.storage[strid].idata) do
			local x = game.FrameworkInternalService:Var2Val(v)
			x.Name = i
			x.Parent = InternalData
		end
		
		ClientDataProfile.Parent = self.ClientDataReplicator
		
		if game.Players:GetPlayerByUserId(id) then
			self.storage[strid].player = game.Players:GetPlayerByUserId(id)
			
			local c
			c = game.Players.PlayerRemoving:connect(function(p)
				if p == self.storage[strid].player then
					c:disconnect()
					delay(3, function()
						if not self.storage[strid] or game.Players:GetPlayerByUserId(id) then return end
						self.storage[strid]:Save()
						game.PlayerDataService:UnloadData(self.storage[strid].userid, self.storage[strid].profile)
					end)
				end
			end)
		end
		
		local _self = self.storage[strid]
		local function touch(_, i)
			if _ and not i then
				self.storage[strid].touched[_] = os.time()
			elseif _ and i then
				self.storage[strid].itouched[_] = os.time()
			end
			if i then
				self.storage[strid].ilastTouch = os.time()
			else
				self.storage[strid].lastTouch = os.time()
			end
		end
		
		local function edit(_, i)
			if _ and not i then
				self.storage[strid].edited[_] = os.time()
			elseif _ and i then
				self.storage[strid].iedited[_] = os.time()
			end
			if i then
				self.storage[strid].ilastEdit = os.time()
			else
				self.storage[strid].lastEdit = os.time()
			end
		end
		
		function _self:Get(Key)
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Get(Key)
			end
			
			touch(Key)
			return game.PlayerDataService.storage[strid].data[Key]
		end
		
		function _self:Set(Key, Value)
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Set(Key, Value)
			end
			
			local old = game.PlayerDataService.storage[strid].data[Key]
			if old == Value then return end
			
			if PlayerData:findFirstChild(Key) then
				game.FrameworkInternalService:UpdateVal(PlayerData[Key], Value)
			else
				local x = game.FrameworkInternalService:Var2Val(Value)
				x.Name = Key
				x.Parent = PlayerData
			end
			
			game.PlayerDataService.storage[strid].data[Key] = Value
			touch(Key)
			edit(Key)
			game.PlayerDataService.storage[strid].Changed:fire(Key, Value, old)
		end
		
		function _self:iGet(Key)
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):iGet(Key)
			end
			
			touch(Key, true)
			return game.PlayerDataService.storage[strid].idata[Key]
		end
		
		function _self:iSet(Key, Value)
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):iSet(Key, Value)
			end
			
			local old = game.PlayerDataService.storage[strid].idata[Key]
			if old == Value then return end
			
			if InternalData:findFirstChild(Key) then
				game.FrameworkInternalService:UpdateVal(InternalData[Key], Value)
			else
				local x = game.FrameworkInternalService:Var2Val(Value)
				x.Name = Key
				x.Parent = InternalData
			end
			
			game.PlayerDataService.storage[strid].idata[Key] = Value
			touch(Key, true)
			edit(Key, true)
			game.PlayerDataService.storage[strid].iChanged:fire(Key, Value, old)
		end
		
		function _self:Delete()
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Delete()
			end
			
			for _,v in pairs(game.PlayerDataService.storage[strid].data) do
				game.PlayerDataService.storage[strid].Changed:fire(_, nil, v)
				touch(_)
			end
			
			game.PlayerDataService.storage[strid].data = {}
		end
		
		function _self:Save()
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Save()
			end
			
			if game.PlayerDataService.storage[strid].lastSave > game.PlayerDataService.storage[strid].lastEdit or id <= 0 then return end
			
			game.PlayerDataService.storage[strid].lastSave = os.time()
			local u = _self:iGet("username") or ("Player#" .. id)
			local d = game.FrameworkService:Serialize({player = game.PlayerDataService.storage[strid].data, internal = game.PlayerDataService.storage[strid].idata, lastTouch = game.PlayerDataService.storage[strid].lastTouch, lastSave = game.PlayerDataService.storage[strid].lastSave}, true)
			
			game.FrameworkHttpService:Post("playerdata_set", {UserID = id, Profile = profile, Data = d, Username = u, PlayerInfo = _self:iGet("PlayerInfo") or {}}, {json = true})
			Databases[profile]:SetAsync("PlayerList$" .. id, d)
		end
		
		function _self:Update(Keys, UpdateFunctions)
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Update(Keys, UpdateFunctions)
			end
			
			if typeof(Keys) == "table" then
				if typeof(UpdateFunctions) == "table" then
					for _,v in pairs(Keys) do
						local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
						game.PlayerDataService.storage[strid]:Set(v, f(game.PlayerDataService.storage[strid]:Get(v)))
					end
				elseif typeof(UpdateFunctions) == "function" then
					for _,v in pairs(Keys) do
						local f = UpdateFunctions
						game.PlayerDataService.storage[strid]:Set(v, f(game.PlayerDataService.storage[strid]:Get(v)))
					end
				end
			else
				if typeof(UpdateFunctions) == "table" then
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					game.PlayerDataService.storage[strid]:Set(Keys, f(game.PlayerDataService.storage[strid]:Get(Keys)))
				elseif typeof(UpdateFunctions) == "function" then
					local f = UpdateFunctions
					game.PlayerDataService.storage[strid]:Set(Keys, f(game.PlayerDataService.storage[strid]:Get(Keys)))
				end
			end
		end
		
		function _self:GetKeys()
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):GetKeys()
			end
			
			local Keys = {}
			for _,v in pairs(game.PlayerDataService.storage[strid].data) do
				table.insert(Keys, _)
			end
			
			touch()
			
			return Keys
		end
		
		function _self:GetPlayer()
			if not game.PlayerDataService.storage[strid] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):GetPlayer()
			end
			
			return game.PlayerDataService.storage[strid].player
		end
		
		self.locked[strid] = false
		return self.storage[strid]
	end,
	UnloadData = function(self, player, profile)
		game.FrameworkService:CheckArgument(debug.traceback(), "UnloadData", 1, player, {"number","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "UnloadData", 2, profile, {"number","nil"})
		
		game.FrameworkService:LockServer(debug.traceback(), "UnloadData")--
		
		if profile and (profile < 1 or profile > 5) then error("Profile must be a number from 1 to 5") end
		
		if not profile then profile = 1 end
		
		local id = player
		if typeof(player) == "Instance" and not player:IsA("Player") then
			return
		elseif typeof(player) == "Instance" then
			id = player.userId
		end
		
		local strid = id .. "-" .. profile
		self.storage[strid] = nil
	end,
	SaveData = function(self, player, profile)
		game.FrameworkService:CheckArgument(debug.traceback(), "SaveData", 1, player, {"number","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "SaveData", 2, profile, {"number","nil"})
		
		game.FrameworkService:LockServer(debug.traceback(), "SaveData")
		
		if profile and (profile < 1 or profile > 5) then error("Profile must be a number from 1 to 5") end
		
		if not profile then profile = 1 end
		
		local id = player
		if typeof(player) == "Instance" and not player:IsA("Player") then
			return
		elseif typeof(player) == "Instance" then
			id = player.userId
		end
		
		local strid = id .. "-" .. profile
		if self.storage[strid] then
			return self.storage[strid]:Save()
		else
			warn("No data for " .. player .. " found, can't save.")
		end
	end,
	DeleteData = function(self, player, profile)
		game.FrameworkService:CheckArgument(debug.traceback(), "DeleteData", 1, player, {"number","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "DeleteData", 2, profile, {"number","nil"})
		
		game.FrameworkService:LockServer(debug.traceback(), "DeleteData")
		
		if profile and (profile < 1 or profile > 5) then error("Profile must be a number from 1 to 5") end
		
		if not profile then profile = 1 end
		
		local id = player
		if typeof(player) == "Instance" and not player:IsA("Player") then
			return
		elseif typeof(player) == "Instance" then
			id = player.userId
		end
		
		local strid = id .. "-" .. profile
		if self.storage[strid] then
			return self.storage[strid]:Delete()
		else
			return self:LoadData(player, profile):Delete()
		end
	end,
	CloneData = function(self, player, profile1, profile2)
		game.FrameworkService:CheckArgument(debug.traceback(), "CloneData", 1, player, {"number","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "CloneData", 2, profile1, {"number","nil"})
		game.FrameworkService:CheckArgument(debug.traceback(), "CloneData", 3, profile2, {"number","nil"})
		
		game.FrameworkService:LockServer(debug.traceback(), "CloneData")
		
		if profile1 and (profile1 < 1 or profile1 > 5) then error("Profile must be a number from 1 to 5") end
		if not profile1 then profile1 = 1 end
		if profile2 and (profile2 < 1 or profile2 > 5) then error("Profile must be a number from 1 to 5") end
		if not profile2 then profile2 = 1 end
		
		local id = player
		if typeof(player) == "Instance" and not player:IsA("Player") then
			return
		elseif typeof(player) == "Instance" then
			id = player.userId
		end
		
		local strid = id .. "-" .. profile1
		local strid2 = id .. "-" .. profile2
		
		if not self.storage[strid] then
			self:LoadData(player, profile1)
		end
		if not self.storage[strid2] then
			self:LoadData(player, profile2)
		end
		
		if not self.storage[strid] or not self.storage[strid2] then
			error("Unexpected error")
		end
		
		self.storage[strid2]:Delete()
		local keys = self.storage[strid]:GetKeys()
		for _,v in pairs(keys) do
			self.storage[strid2]:Set(v, self.storage[strid]:Get(v))
		end
		
		return true
	end,
	WaitForData = function(self, player, profile)
		game.FrameworkService:CheckArgument(debug.traceback(), "WaitForData", 1, player, {"number","Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "WaitForData", 2, profile, {"number","nil"})
		
		if profile and (profile < 1 or profile > 5) then error("Profile must be a number from 1 to 5") end
		
		if not profile then profile = 1 end
		
		local id = player
		if typeof(player) == "Instance" and not player:IsA("Player") then
			return
		elseif typeof(player) == "Instance" then
			id = player.userId
		end
		
		local strid = id .. "-" .. profile
		if not self.storage[strid] then
			if not self.locked[strid] and game:Is("Server") then
				self:LoadData(player, profile)
			end
			
			local n = os.time() + 5
			repeat
				wait()
				if n <= os.time() and game:Is("Server") then
					n = os.time() + 30
					self:LoadData(player, profile)
				end
			until self.storage[strid]
		end
		
		return self.storage[strid]
	end,
}}