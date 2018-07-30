-- An internal service which handles player's data.

local Databases = {}--
local storage = {}
local locked = {}
local dataCon = {}
--setmetatable(storage, {__mode = "k"})
--setmetatable(locked, {__mode = "k"})

return {"PlayerDataService", "PlayerDataService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l
		if game:Is("Server") then
			if game:GetFrameworkModule():FindFirstChild("ClientDataReplicator") then
				game:GetFrameworkModule().ClientDataReplicator:Destroy()
			end

			local ClientDataReplicator = Instance.new("Folder")
			ClientDataReplicator.Parent = game:GetFrameworkModule()
			ClientDataReplicator.Name = "ClientDataReplicator"
			self:SetProperty("ClientDataReplicator", ClientDataReplicator)

			pcall(function()
				Databases[1] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData") -- for compatibility with framework v2 and v1
				Databases[2] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData2")
				Databases[3] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData3")
				Databases[4] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData4")
				Databases[5] = game:GetService("DataStoreService"):GetDataStore("PlayerDataStore_PlayerData5")
			end)

			game.ThreadService:Thread(function()
				for _,v in pairs(storage) do
					if v and v.lastTouch then
						if v.lastTouch + game.FrameworkHttpService.UnloadDelay <= os.time() then -- hasn't been touched in 2.5 minutes, unload it if they aren't in-game
							if not game.Players:GetPlayerByUserId(v.userid) then
								v:Save()

								game.PlayerDataService:UnloadData(v.userid, v.profile)
							end
						end
					end

					if v.AutoSave and v.lastSave and v.lastSave + game.FrameworkHttpService.AutosaveDelay <= os.time() then
						spawn(function() v:Save() end)
					end
				end
			end, {delay = 30, yield = false})

			game:BindToClose(function()
				wait(2)
				for _,v in pairs(storage) do
					v:Save()
				end
			end)
		else
			-- We are going to replicate how the server handle's data to a read-only version on the client. We'll be using values and changed event listeners for efficiency purposes.
			self:SetProperty("ClientDataReplicator", game:GetFrameworkModule():WaitForChild("ClientDataReplicator"))

			local function ClientDataProfile(Data)
				Data:WaitForChild("InternalData", 5)
				if not Data:findFirstChild("InternalData") then return warn("Couldn't load data:",Data) end
				Data:WaitForChild("PlayerData", 5)
				if not Data:findFirstChild("PlayerData") then return warn("Couldn't load data:",Data) end

				local strid = Data.Name
				local split = string.split(strid, "-")
				local id = tonumber(split[1])
				local profile = tonumber(split[2])
				local _self = {}
				_self.userid = id
				_self.profile = profile
				_self.data = {}
				_self.idata = {}
				_self.touched = {}
				_self.itouched = {}
				_self.lastTouch = 0
				_self.ilastTouch = 0
				_self.edited = {}
				_self.iedited = {}
				_self.lastEdit = 0
				_self.lastSave = 0
				_self.ilastEdit = 0
				_self.AutoSave = nil -- we dont need this rite?
				_self.Changed = LoadLibrary("RbxUtility"):CreateSignal()
				_self.iChanged = LoadLibrary("RbxUtility"):CreateSignal()

				local function setupVal(v, internal)
					local oldv = game.FrameworkInternalService:Val2Var(v)
					v.Changed:connect(function()
						local val = game.FrameworkInternalService:Val2Var(v)
						if val == oldv then return end

						if internal then
							_self.idata[v.Name] = val
							_self.iChanged:fire(v.Name, val, oldv)
						else
							_self.data[v.Name] = val
							_self.Changed:fire(v.Name, val, oldv)
						end--

						oldv = val
					end)
				end

				Data.InternalData.ChildAdded:connect(function(v)
					local old = _self.idata[v.Name]
					_self.idata[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v, true)

					if old then
						_self.iChanged:fire(v.Name, _self.idata[v.Name], old)
					else
						_self.iChanged:fire(v.Name, _self.idata[v.Name], nil)
					end
				end)
				Data.InternalData.ChildRemoved:connect(function(v)
					if _self.idata[v.Name] ~= nil then
						_self.iChanged:fire(v.Name, nil, _self.idata[v.Name])
					end

					_self.idata[v.Name] = nil
				end)

				Data.PlayerData.ChildAdded:connect(function(v)
					local old = _self.data[v.Name]
					_self.data[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v, true)

					if old then
						_self.Changed:fire(v.Name, _self.data[v.Name], old)
					else
						_self.Changed:fire(v.Name, _self.data[v.Name], nil)
					end
				end)
				Data.PlayerData.ChildRemoved:connect(function(v)
					if _self.data[v.Name] ~= nil then
						_self.Changed:fire(v.Name, nil, _self.data[v.Name])
					end

					_self.data[v.Name] = nil
				end)

				for _,v in pairs(Data.InternalData:GetChildren()) do
					_self.idata[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v, true)
				end

				for _,v in pairs(Data.PlayerData:GetChildren()) do
					_self.data[v.Name] = game.FrameworkInternalService:Val2Var(v)
					setupVal(v)
				end

				if game.Players:GetPlayerByUserId(id) then
					_self.player = game.Players:GetPlayerByUserId(id)
				end

				function _self:Get(Key)
					if not storage[_self.userid .. "-" .. _self.profile] then
						return warn("Cannot Get, save for " .. id .. " has been unloaded by the server.")
					end

					return storage[_self.userid .. "-" .. _self.profile].data[Key]
				end

				function _self:iGet(Key)
					if not storage[_self.userid .. "-" .. _self.profile] then
						return warn("Cannot iGet, save for " .. id .. " has been unloaded by the server.")
					end

					return storage[_self.userid .. "-" .. _self.profile].idata[Key]
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
					if not storage[_self.userid .. "-" .. _self.profile] then
						return warn("Cannot GetKeys, save for " .. id .. " has been unloaded by the server.")
					end

					local Keys = {}
					for _,v in pairs(storage[_self.userid .. "-" .. _self.profile].data) do
						table.insert(Keys, _)
					end

					return Keys
				end

				function _self:GetPlayer()
					if not storage[_self.userid .. "-" .. _self.profile] then
						return warn("Cannot GetPlayer, save for " .. id .. " has been unloaded by the server.")
					end

					return storage[_self.userid .. "-" .. _self.profile].player
				end

				storage[strid] = _self
			end

			local Children = self.ClientDataReplicator:GetChildren()
			self.ClientDataReplicator.ChildAdded:connect(function(Child)
				ClientDataProfile(Child)
			end)
			self.ClientDataReplicator.ChildRemoved:connect(function(Child)
				pcall(function() storage[Child.Name].Changed:disconnect() end)
				pcall(function() storage[Child.Name].iChanged:disconnect() end)
				storage[Child.Name] = nil
			end)

			for _,v in pairs(Children) do
				ClientDataProfile(v)
			end
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	storage = storage,
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
		if locked[strid] then
			return self:WaitForData(player, profile)
		elseif storage[strid] and not nocache then
			return storage[strid]
		end

		locked[strid] = true


		local _self = {}

		local function banCheck(data)
			if data.internal['Banned'] and data.internal["BanLift"] and data.internal["BanLift"] > os.time() then
				delay(1, function()
					local diff = data.internal["BanLift"] - os.time()

					local weeks = math.floor(diff / 60 / 60 / 24 / 7)
					if weeks >= 1 then
						diff = diff - (weeks * (60 * 60 * 24 * 7))
					end
					local days = math.floor(diff / 60 / 60 / 24)
					if days >= 1 then
						diff = diff - (days * (60 * 60 * 24))
					end
					local hours = math.floor(diff / 60 / 60)
					if hours >= 1 then
						diff = diff - (hours * (60 * 60))
					end
					local minutes = math.floor(diff / 60)
					if minutes >= 1 then
						diff = diff - (minutes * (60))
					end
					local seconds = math.floor(diff)

					local t = ""
					if weeks >= 1 then
						t = t .. weeks .. " Weeks "
					end
					if days >= 1 then
						t = t .. days .. " Days "
					end
					if hours >= 1 then
						t = t .. hours .. " Hours "
					end
					if minutes >= 1 then
						t = t .. minutes .. " Minutes "
					end

					if seconds >= 1 then
						t = t .. seconds .. " Seconds "
					end

					if not _self.player then return end
					_self.player:Kick("You are currently banned from the game!\n\nReason: " .. (data.internal["BanReason"] or "N/A")  .. "\nTime left: " .. t)
				end)
			end
		end



		local data = {}
		local setBanData
		if id >= 1 then
			--print"PD1"
			local CompletedReq = false
			local StopTime = tick()+5
			spawn(function()
				data = game.FrameworkHttpService:Post("playerdata_get", {UserID = id, Profile = profile}, {json = true})
				CompletedReq = true
			end)

			local data2
			pcall(function()
				data2 = Databases[profile]:GetAsync("PlayerList$" .. id)
			end)

			while not CompletedReq and StopTime > tick() do wait() end

			--print"PD2"
			local success
			if data and type(data) == "table" then
				if data.success == false and data.error == 404 and data.message then
					if data.banned and game.Players:GetPlayerByUserId(id) then
						local Plr = game.Players:GetPlayerByUserId(id)

						if Plr then
							_self.player = Plr
							setBanData = {Banned = true, BanLift = tonumber(data.banned[2]), BanReason = data.banned[3]}
							banCheck({internal = {Banned = true, BanLift = tonumber(data.banned[2]), BanReason = data.banned[3]}})
						end

					end
					-- couldn't find their data in the database
					data = {}
				elseif data.success then
					success = true
					if not pcall(function()
						data = game.HttpService:JSONDecode(data.data)
					end) then
						success = false
					end
				end
			end
			--print"PD3"
			if not success and data2 then
				game.FrameworkService:DebugOutput("Webserver unavailable, using DataStore save instead.")
				data = data2
			else
				if data2 and data2.lastSave and data.lastSave and data.lastSave < data2.lastSave then
					game.FrameworkService:DebugOutput("DataStore save is newer than WebServer save, using it instead.")
					data = data2
					print("MEH!")
				end
			end
		else
			data = {}
		end

		if not data then data = {} end

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


		if id >= 1 then
			pcall(function()
				_self.DBCon = Databases[profile]:OnUpdate("PlayerList$" .. id, function(UpdatedData)
					if UpdatedData._____serialized then
						UpdatedData = game.FrameworkService:Unserialize(UpdatedData)
					end

					if not UpdatedData.player or not UpdatedData.internal then
						UpdatedData = {player = UpdatedData or {}, internal = {created = os.time()}, lastSave = 0}
					end

					if UpdatedData.internal.KeyTimestamps then
						if not storage[_self.userid .. "-" .. _self.profile] or not storage[_self.userid .. "-" .. _self.profile].internal or game.Players:GetPlayerByUserId(id) then return pcall(function() _self.DBCon:disconnect() end) end

						if storage[_self.userid .. "-" .. _self.profile].internal.KeyTimestamps then
							for k,t1 in pairs(UpdatedData.internal.KeyTimestamps) do
								local t2 = storage[_self.userid .. "-" .. _self.profile].internal.KeyTimestamps[k]

								if t1 and not t2 then
									-- update
									storage[_self.userid .. "-" .. _self.profile]:Set(k, UpdatedData.player[k])
								elseif not t1 and t2 then
									-- dont update?
								elseif t1 and t2 and t1 > t2 then
									-- update
									storage[_self.userid .. "-" .. _self.profile]:Set(k, UpdatedData.player[k])
								end
							end
						end
					end

					if profile == 1 then banCheck(UpdatedData) end
				end)
			end)
		end

		_self.userid = id
		_self.profile = profile
		_self.data = data.player
		_self.idata = data.internal
		_self.idata.KeyTimestamps = {}
		_self.touched = {}
		_self.itouched = {}
		_self.lastTouch = data.lastTouch or os.time()
		_self.ilastTouch = data.lastTouch or os.time()
		_self.edited = {}
		_self.iedited = {}
		_self.lastEdit = data.lastTouch or os.time()
		_self.lastSave = data.lastSave or os.time()
		_self.ilastEdit = data.lastTouch or os.time()
		_self.AutoSave = true
		_self.Changed = LoadLibrary("RbxUtility"):CreateSignal()
		_self.iChanged = LoadLibrary("RbxUtility"):CreateSignal()

		local ClientDataProfile = Instance.new("Folder")
		ClientDataProfile.Name = strid
		local PlayerData = Instance.new("Folder", ClientDataProfile)
		PlayerData.Parent = ClientDataProfile
		PlayerData.Name = "PlayerData"
		local InternalData = Instance.new("Folder", ClientDataProfile)
		InternalData.Parent = ClientDataProfile
		InternalData.Name = "InternalData"

		for i,v in pairs(_self.data) do
			local x = game.FrameworkInternalService:Var2Val(v)
			x.Name = i
			x.Parent = PlayerData
		end

		for i,v in pairs(_self.idata) do
			local x = game.FrameworkInternalService:Var2Val(v)
			x.Name = i
			x.Parent = InternalData
		end

		ClientDataProfile.Parent = self.ClientDataReplicator

		if game.Players:GetPlayerByUserId(id) then
			_self.player = game.Players:GetPlayerByUserId(id)

			_self.c = game.Players.PlayerRemoving:connect(function(p)
				if p == _self.player then
					_self:Save()
					delay(10, function()
						if not storage[_self.userid .. "-" .. _self.profile] or game.Players:GetPlayerByUserId(id) then return end
						storage[_self.userid .. "-" .. _self.profile]:Save()
						game.PlayerDataService:UnloadData(_self.userid, _self.profile)
					end)
				end
			end)
		end

		if profile ~= 1 and _self.player then
			spawn(function()
				game.PlayerDataService:LoadData(id, 1)
			end)
		elseif _self.player then
			banCheck(data)
		end

		local function touch(_, i)
			if _ and not i then
				storage[_self.userid .. "-" .. _self.profile].touched[_] = os.time()
			elseif _ and i then
				storage[_self.userid .. "-" .. _self.profile].itouched[_] = os.time()
			end
			if i then
				storage[_self.userid .. "-" .. _self.profile].ilastTouch = os.time()
			else
				storage[_self.userid .. "-" .. _self.profile].lastTouch = os.time()
			end
		end

		local function edit(_, i)
			if _ and not i then
				storage[_self.userid .. "-" .. _self.profile].edited[_] = os.time()
			elseif _ and i then
				storage[_self.userid .. "-" .. _self.profile].iedited[_] = os.time()
			end
			if i then
				storage[_self.userid .. "-" .. _self.profile].ilastEdit = os.time()
			else
				storage[_self.userid .. "-" .. _self.profile].lastEdit = os.time()
			end
		end

		function _self:Get(Key)
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Get(Key)
			end

			touch(Key)
			return storage[_self.userid .. "-" .. _self.profile].data[Key]
		end

		function _self:Set(Key, Value)
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Set(Key, Value)
			end

			local old = storage[_self.userid .. "-" .. _self.profile].data[Key]
			if old == Value then return end

			if PlayerData:findFirstChild(Key) then
				game.FrameworkInternalService:UpdateVal(PlayerData[Key], Value)
			else
				local x = game.FrameworkInternalService:Var2Val(Value)
				x.Name = Key
				x.Parent = PlayerData
			end

			pcall(function()
				storage[_self.userid .. "-" .. _self.profile].internal.KeyTimestamps[Key] = os.time()
			end)

			storage[_self.userid .. "-" .. _self.profile].data[Key] = Value
			touch(Key)
			edit(Key)
			storage[_self.userid .. "-" .. _self.profile].Changed:fire(Key, Value, old)
		end

		function _self:iGet(Key)
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):iGet(Key)
			end

			touch(Key, true)
			return storage[_self.userid .. "-" .. _self.profile].idata[Key]
		end

		function _self:iSet(Key, Value)
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):iSet(Key, Value)
			end

			local old = storage[_self.userid .. "-" .. _self.profile].idata[Key]
			if old == Value then return end

			if InternalData:findFirstChild(Key) then
				game.FrameworkInternalService:UpdateVal(InternalData[Key], Value)--
			else
				local x = game.FrameworkInternalService:Var2Val(Value)
				x.Name = Key
				x.Parent = InternalData
			end

			storage[_self.userid .. "-" .. _self.profile].idata[Key] = Value
			touch(Key, true)
			edit(Key, true)
			storage[_self.userid .. "-" .. _self.profile].iChanged:fire(Key, Value, old)
		end

		function _self:Delete()
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Delete()
			end

			for _,v in pairs(storage[_self.userid .. "-" .. _self.profile].data) do
				storage[_self.userid .. "-" .. _self.profile].Changed:fire(_, nil, v)
				touch(_)
			end

			storage[_self.userid .. "-" .. _self.profile].data = {}
		end

		function _self:Save()
			--print(_self.userid .. "-" .. _self.profile)
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Save()
			end


			if storage[_self.userid .. "-" .. _self.profile].lastSave > os.time() then storage[_self.userid .. "-" .. _self.profile].lastSave = storage[_self.userid .. "-" .. _self.profile].lastEdit end
			if storage[_self.userid .. "-" .. _self.profile].lastSave > storage[_self.userid .. "-" .. _self.profile].lastEdit or id <= 0 then return end

			storage[_self.userid .. "-" .. _self.profile].lastSave = os.time()
			local u = _self:iGet("username") or ("Player#" .. id)
			local d = game.FrameworkService:LightSerialize({player = storage[_self.userid .. "-" .. _self.profile].data, internal = storage[_self.userid .. "-" .. _self.profile].idata, lastTouch = storage[_self.userid .. "-" .. _self.profile].lastTouch, lastSave = storage[_self.userid .. "-" .. _self.profile].lastSave}, true)

			game.FrameworkHttpService:Post("playerdata_set", {UserID = id, Profile = profile, Data = d, Username = u, PlayerInfo = _self:iGet("PlayerInfo") or {}}, {json = true})
			pcall(function() Databases[profile]:SetAsync("PlayerList$" .. id, d) end)
		end

		function _self:Update(Keys, UpdateFunctions)
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):Update(Keys, UpdateFunctions)
			end

			if typeof(Keys) == "table" then
				if typeof(UpdateFunctions) == "table" then
					for _,v in pairs(Keys) do
						local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
						storage[_self.userid .. "-" .. _self.profile]:Set(v, f(storage[_self.userid .. "-" .. _self.profile]:Get(v)))
					end
				elseif typeof(UpdateFunctions) == "function" then
					for _,v in pairs(Keys) do
						local f = UpdateFunctions
						storage[_self.userid .. "-" .. _self.profile]:Set(v, f(storage[_self.userid .. "-" .. _self.profile]:Get(v)))
					end
				end
			else
				if typeof(UpdateFunctions) == "table" then
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					storage[_self.userid .. "-" .. _self.profile]:Set(Keys, f(storage[_self.userid .. "-" .. _self.profile]:Get(Keys)))
				elseif typeof(UpdateFunctions) == "function" then
					local f = UpdateFunctions
					storage[_self.userid .. "-" .. _self.profile]:Set(Keys, f(storage[_self.userid .. "-" .. _self.profile]:Get(Keys)))
				end
			end
		end

		function _self:GetKeys()
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):GetKeys()
			end

			local Keys = {}
			for _,v in pairs(storage[_self.userid .. "-" .. _self.profile].data) do
				table.insert(Keys, _)
			end

			touch()

			return Keys
		end

		function _self:GetPlayer()
			if not storage[_self.userid .. "-" .. _self.profile] then
				-- data has been unloaded but was cached as a variable, reload it
				return game.PlayerDataService:LoadData(id, profile):GetPlayer()
			end

			return storage[_self.userid .. "-" .. _self.profile].player
		end

		if setBanData then
			for _,v in pairs(setBanData) do
				_self:iSet(_, v)
			end
		end


		storage[strid] = _self

		if _self.player then
			_self:iSet("username", _self.player.Name)
		end--

		locked[strid] = false
		return storage[strid]
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
		pcall(function() storage[strid].c:disconnect() end)
		pcall(function() storage[strid].DBCon:disconnect() end)
		storage[strid] = nil
		locked[strid] = nil
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
		if storage[strid] then
			return storage[strid]:Save()
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
		if storage[strid] then
			return storage[strid]:Delete()
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

		if not storage[strid] then
			self:LoadData(player, profile1)
		end
		if not storage[strid2] then
			self:LoadData(player, profile2)
		end

		if not storage[strid] or not storage[strid2] then
			error("Unexpected error")
		end

		storage[strid2]:Delete()
		local keys = storage[strid]:GetKeys()
		for _,v in pairs(keys) do
			storage[strid2]:Set(v, storage[strid]:Get(v))
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
		if not storage[strid] then
			if not locked[strid] and game:Is("Server") then
				self:LoadData(player, profile)
			end

			local n = os.time() + 5
			repeat
				wait()
				if n <= os.time() and game:Is("Server") then
					n = os.time() + 30
					self:LoadData(player, profile)
				end
			until storage[strid]
		end

		return storage[strid]
	end,
}}
