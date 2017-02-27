--[[
	File: XeptixDataStorage.lua
	Author: Xeptix
	Info: Handles player data storage.
--]]


if game.Players.LocalPlayer then
	return nil
end


framework = _G.premature_framework


local Database
pcall(function()
	Database = game:GetService("DataStoreService"):GetDataStore(framework.Settings.PlayerSaveDatabaseName)
end)
if not Database then Database = _G.XeptixFramework_PesudoDS() end

Module = {}
Module.Cache = {} -- when the data is loaded the cache goes here

local DataBackupsDisabled = false
--todo: make it so the internal tables XeptixFramework/? are tables not json anymore.

local LC = {}
local LoadQueue = tick()
function Module:Load(UserID, BypassCache) -- if BypassCache is true, it will fetch the data from the database ignoring the cahce (i.e if they join, go to a different server, then come back to this server, the data is up to date)
	if LC[tostring(UserID)] then return framework:WaitForData(UserID) end
	LC[tostring(UserID)] = true	
	
	if Module.Cache[tostring(UserID)] and not BypassCache then
		LC[tostring(UserID)] = false
		return Module.Cache[tostring(UserID)]
	end
	
	if LoadQueue > tick() then
		repeat wait() until LoadQueue <= tick()
		LoadQueue = tick() + 0.75
	end
	
	
	local Save = {
		dataSet = {},
		userId = UserID,
		nextDCPush = tick(),
		lastSaved = 0, -- if the lastSaved is >= to lastEdit, don't save (nothing was changed)
		lastEdit = tick(),
		lastTouched = tick(), -- after it isn't touched for 10? minutes, unload it
	}
	
	local PKey = 'PlayerList$'..UserID
	if UserID <= 0 then
		PKey = 'PlayerList$'..UserID..'$'..math.floor(tick())
	end
	
	Save.PKey = PKey
	
	
	-- Load the data
	local DCD, RawDCD
	local ds
	if UserID > 0 then
		for i = 1,3 do -- try three times to get their data from the datastore, if it can't find it try to find a backup
			pcall(function() ds = Database:GetAsync(PKey) if type(ds) ~= "table" then ds = nil end end)
			if not ds then wait(0.1) else break end
		end
	end
	
	if framework.DCC and not ds and not DataBackupsDisabled and UserID > 0 then
		for i = 1,10 do -- try 10 times to get a backup, or else rip their data forever...
			local DevCircleSave
			local NoSaveForPlayer -- they have no backups in the database
			pcall(function()
				RawDCD = framework:internalrequest('42069','DCRequest','database/getV2', 'post', {Timestamp = tick(), UserID = UserID})
				if RawDCD == "disabled" then
					DataBackupsDisabled = true
					return
				elseif RawDCD == "noSaveFoundFor"..tostring(UserID) then
					NoSaveForPlayer = true
				end
				DevCircleSave = framework:DecodeJSON(RawDCD)
			end)
			
			if DevCircleSave and type(DevCircleSave) == "table" then
				DCD = DevCircleSave
				--print("Successfully found DevCircle backup save for:",UserID)
				break
			elseif NoSaveForPlayer then
				--print("Couldn't find DevCircle backup save for:",UserID)
				break
			end
			
			if DataBackupsDisabled then break end
		end
		
		if DCD then
			print(UserID, "USING DEVCIRCLE DATA!!! COULDNT FIND REAL DATA!!")
			ds = DCD
			--print(framework:EncodeJSON(DCD))
		else
			--print(UserID, "COULDNT LOAD DATA OR DC BACKUP!!!")
			--print(DCD)
			
			--Instance.new("Message", workspace).Text = tostring(RawDCD)
		end
	end
	
	Save.dataSet = ds
	if not Save.dataSet then
		Database:SetAsync(PKey, {})
		Save.dataSet = {}
	end
	
	if not Save.dataSet["XF_KeyChangeTimestamps"] then
		Save.dataSet.XF_KeyChangeTimestamps = {}
	else
		local highest = 0
		for _,v in pairs(Save.dataSet.XF_KeyChangeTimestamps) do
			if v > highest then
				highest = v
			end
		end
		
		if highest <= tick() - (3600 * 24) then -- the last time any keys were changed was 24 hours ago, let's rip the table.
			Save.dataSet.XF_KeyChangeTimestamps = {}
		end
	end
	
	
	
	
	-- Listen for other servers to change the data
	function OnUpdate(Data)
		if not Data then
			Data = {}
		end
		
		if Data.XF_KeyChangeTimestamps and Save and Save.dataSet then
			for _,v in pairs(Data.XF_KeyChangeTimestamps) do
				if not Save.dataSet.XF_KeyChangeTimestamps or (Save.dataSet.XF_KeyChangeTimestamps[_] and v > Save.dataSet.XF_KeyChangeTimestamps[_]) or not Save.dataSet.XF_KeyChangeTimestamps[_] then
					-- the other server changed this key AFTER we changed it in this one, overwrite it
					Save:Set(_, Data[_])
				end
			end
		end
	end
	
	Save.OUC = Database:OnUpdate(PKey, OnUpdate)
	
	
	-- API
	function Save:GetKeys()
		local keys = {}

		for _,v in pairs(Save.dataSet or {}) do
			-- filter out internal ones, just like on the server
			if _:sub(0,16) == "XeptixFramework/" or _:sub(0,22) == "XF_KeyChangeTimestamps" then
				-- do nothing for now
			else
				table.insert(keys, _)
			end
		end

		return keys
	end
	function Save:Set(Key, Value)		
		if Key == "XF_KeyChangeTimestamps" then return end -- nop'd
		if not Save.dataSet then return end
		
		Key = tostring(Key)
		local Old = Save.dataSet[Key]
		if Old == Value and framework:Type(Value) ~= "table" then
			return -- why change it???
		end
		
		if Key ~= 'XeptixFramework/LastSaved' then
			Save.lastTouched = tick()
			Save.lastEdit = tick()
		end
		
		if type(Value) == "number" then
			if tostring(Value):find("e") then
				Value = tonumber(tostring(Value)) or 0
			end
			
			if tonumber(tostring(Value)) == nil then
				if tostring(Value) == "1.#INF" then
					Value = 2147483647
				elseif tostring(Value) == "-1.#INF" then
					Value = -2147483647
				else
					Value = 0
				end
			end
			
			if Value > 2147483646 then
				Value = 2147483646
			elseif Value < -2147483646 then
				Value = -2147483646
			end
		end
		
		Save.dataSet[Key] = Value
		if Save.dataSet.XF_KeyChangeTimestamps then
			Save.dataSet.XF_KeyChangeTimestamps[Key] = math.floor(tick())
		end
		
		local ReplicateData = framework._ReplicateDataContainer:findFirstChild(tostring(Save.userId))
		local ValObj = ReplicateData and ReplicateData:findFirstChild(Key)
		if ReplicateData and ValObj and not ValObj:IsA("Model") and framework:Type(Value) == framework:Type(ValObj.Value) then
			ValObj.Value = Value
		elseif ReplicateData and ValObj and ValObj:IsA("StringValue") and ValObj:findFirstChild("<json>") and framework:Type(Value) == "table" then
			--print("Nop'd JSON!")
			ValObj.Value = framework:EncodeJSON(Value)
		elseif ReplicateData then
			framework:addKeyToReplicateData(ReplicateData, Key, Value)
		end
		
		local Player = framework:PlayerFromUserID(Save.userId)
		if not Player then
			return -- Nothing more needs to be done here.
		end
		
		framework.KeyChanged:fire(Player, Key, Old, Value)
	end
	
	function Save:Update(KL, FL)
		if not Save.dataSet then return end
		if type(KL) == "string" and type(FL) == "function" then
			Save:Set(KL, FL(Save:Get(KL)))
		elseif type(KL) == "table" and type(FL) == "table" then
			for i, v in pairs(KL) do
				if FL[i] and type(FL[i]) == "function" and type(v) == "string" then
					Save:Set(v, FL[i](Save:Get(v)))
				else
					spawn(function() error("Invalid arguments for Save::Update!") end)
				end
			end
		else
			error("Invalid arguments for Save::Update!")
		end
	end
	
	function Save:Get(Key)
		if not Save.dataSet then return end
		Save.lastTouched = tick()
		
		return Save.dataSet[tostring(Key)]
	end
	
	function Save:Flush()
		--if true then return end -- dont allow saving for testing purposes
		if Save.userId < 0 then return end
		if Save.nextDCPush <= tick() then
			Save.nextDCPush = tick() + 180
			
			local DataClone = Save.dataSet
			if DataClone then
				--spawn(function()
					local ID = Save.userId
					Save:Upload(ID, DataClone)
				--end)
			end
		end
		
		if Save.lastEdit < Save.lastSaved then return end
		Save.lastSaved = tick()
		pcall(function()
			Save:Set('XeptixFramework/LastSaved', Save.lastSaved)
		end)
		
		local DataToSave = Save.dataSet
		if not DataToSave or type(DataToSave) ~= "table" then return end
		
		local function UpdateAsync(Data)
			if not DataToSave then
				return Data -- dont make changes!!!!!
			end
			
			if not Data then
				Data = {}
			end
			
			if Data.XF_KeyChangeTimestamps then
				if Save and DataToSave then
					for _,v in pairs(Data.XF_KeyChangeTimestamps) do
						if not DataToSave.XF_KeyChangeTimestamps or (DataToSave.XF_KeyChangeTimestamps[_] and v > DataToSave.XF_KeyChangeTimestamps[_]) or not DataToSave.XF_KeyChangeTimestamps[_] then
							-- the other server changed this key AFTER we changed it in this one, overwrite it
							pcall(function() Save:Set(_, Data[_]) end)
							DataToSave[_] = Data[_]
						end
					end
				end
			end
			
			--if true then return nil end
			
			return DataToSave
		end
		
		--Database:SetAsync(PKey, Save.dataSet)
		Database:UpdateAsync(Save.PKey, UpdateAsync)
	end
	
	function Save:Save()
		return Save:Flush()
	end
	
	function Save:Upload(ID, DataClone)
		spawn(function()
			if framework.DCC then
				-- Upload the data to DC
				local UploadData = {}
				for _,v in pairs(DataClone) do
					if type(v) == "number" then
						if tostring(v):find("e") then
							v = tonumber(tostring(v))
						end
						if v > 2147483247 then
							v = 2147483247
						elseif v < -2147483247 then
							v = -2147483247
						elseif tostring(v):find("#") then
							v = 0
						end
						
						UploadData[_] = v
					else--if _:sub(0,#"XeptixFramework/") == "XeptixFramework/" then
						UploadData[_] = v
					end
				end
				
				framework:SaveDataToDC(ID, UploadData)
			end
		end)
	end
	
	Save:Set('XeptixFramework/LastSaved', 0)
	Module.Cache[tostring(UserID)] = Save
	
	LC[tostring(UserID)] = false
	return Save
end

function Module:SaveAll()
	for _,v in pairs(Module.Cache) do
		local s, e = pcall(function() v:Save() end)
		if not s then
			warn("XeptixFramework :: Could not save data for",v.userId,"error:",e)
		end
		
		wait(0.5)
	end
end

function Module:UnloadIdleSaves()
	-- this unloads all of the data that hasn't been touched in 5 minutes.
	for _,v in pairs(Module.Cache) do
		if v.lastTouched + (60 * 5) <= tick() and not game.Players:GetPlayerByUserId(v.userId) then
			framework:UnloadData(v.userId)
			v.OUC:disconnect()
			Module.Cache[_] = nil
		end
	end
end


framework.OnClose:connect(function()
	Module:SaveAll()
	
	wait()
	
	for _,v in pairs(game.Players:GetPlayers()) do
		v:Kick()
	end
	
	game.Players.PlayerAdded:connect(function(Player)
		Player:Kick("Whoops! You joined a server that is shutting down!\n\nPlease rejoin the game!")
	end)
end)

framework.PlayerRemoving:connect(function(Player)
	local Data = Module.Cache[tostring(Player.userId)]
	if Data and false then -- disabled for now :/ ffs m8 what could be causing this!!!
		Data.OUC:disconnect()
		
		Data:Save()
		framework:UnloadData(Player)
		Module.Cache[tostring(Player.userId)] = nil
	elseif Data then
		Data:Save() -- might as well save, m8!
	end
end)

return Module