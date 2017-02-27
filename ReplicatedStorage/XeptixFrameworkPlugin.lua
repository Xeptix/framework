--@Version 2.1.6

--[[ Hello! Thank you for using Xeptix Framework!
	Note: Do not rename this module, or you can possibly break the game!
	
	== Description ==
		Xeptix Framework (or XF for short) is a simple and easy to use framework, which
		eases the development proccess by providing many features such as Data Storage,
		Simplified Remotes, Global Leaderboards, Online Server Management, and MUCH more!
			
		Xeptix Framework provides a collection of optional libraries and modules by fellow
		ROBLOX developers. If you've got a module that would be useful to add, feel free
		to PM Xeptix.
			
		As of v2, we have simplified the framework into 1 main module. We also moved the
		documentation to a more organized GUI. To access the documentation, click the
		"Documentation" button under the Xeptix Framework Plugin.
		
		
	== Instructions ==
		Using the framework is easy! Simply require this module with all of the scripts
		that you wish to use the framework with, then you're ready to go!
			Example Code:
			framework = require(game.ReplicatedStorage.XeptixFrameworkModule)
		Note that for the above code to work, you must place this "XeptixFrameworkModule" module in
		ReplicatedStorage
		
		For additional instructions, click the "Documentation" button under the Xeptix
		Framework Plugin.
	
	
	== Want More Features? ==
		For more features, you must connect your game with the DevCircle website.
		This will allow you to manage your servers from the website, use Global Leaderboards,
		see error logs, use cross-universe DataStores, and more!
			(This is completely optional, and is only intended to enhance your experience. This
			in no way requires your password, or any other personal infomation. We will never
			ask for your info!)
			
		To connect this game with DevCircle, click the "Connect This Game" button under the
		Xeptix Framework Plugin.
		
		
	== Want to Contribute? ==
		Check out the official Github! https://github.com/Xeptix/framework
--]]




























































-- Editing the code below will probably break something.
-- Anything you edit will be overwritten when a new update releases.








-- Global variables
start = tick()

MarketplaceService = game:GetService("MarketplaceService")
HttpService = game:GetService("HttpService")
DataStore = game:GetService('DataStoreService')

RbxUtility = LoadLibrary("RbxUtility")
NewSignal = RbxUtility.CreateSignal

Cache = {}
CacheEnabled = false -- experiment plox

--script = game:findFirstChild("XeptixFrameworkModule", true)
Script = script
Stuff = script:WaitForChild("Internal Stuff")
Vars = Stuff:WaitForChild("Var")
Libs = Stuff:WaitForChild("Lib")

Version = Vars.Version.Value

Settings = HttpService:JSONDecode(Vars.SJSON.Value) -- The Settings JSON from the Settings Gui


-- Global functions
function _G.XeptixFramework_PesudoDS() -- for when in studio/offline mode, create a pesudo datastore
	local DS = {Keys = {},OnUpd = NewSignal()}
	function DS:GetAsync(Key)
		return DS.Keys[Key]
	end
	
	function DS:SetAsync(Key, Value)
		if type(Value) == "table" then
			Value = game.HttpService:JSONEncode(Value)
		end
		
		DS.Keys[Key] = Value
		DS.OnUpd:fire(Key)
	end
	
	function DS:UpdateAsync(KeyList, Func)
		if type(Func) ~= "function" then
			local Val = Func
			Func = function()
				return Val
			end
		end
		
		if type(KeyList) == "string" then
			DS:SetAsync(KeyList, Func(DS:GetAsync(KeyList)))
		elseif type(KeyList) == "table" then
			for _,v in pairs(KeyList) do
				DS:SetAsync(v, Func(DS:GetAsync(v)))
			end
		end
	end
	
	function DS:OnUpdate(Key, Func)
		return DS.OnUpd:connect(function(X)
			if X == Key then
				Func(DS:GetAsync(Key))
			end
		end)
	end
	
	return DS
end


function output(text, type)
	local prefix = "Xeptix Framework :: "
	
	if type == 3 then
		return spawn(function() output(text, 2) end)
	elseif type == 2 then
		return error(prefix .. text, 0)
	elseif type == 1 then
		return warn(prefix .. text)
	end
	
	return print(prefix .. text)
end


function SeparateString(String, Separator, UnpackResults)
	local Parts = {}
	for z in String:gmatch("[^"..Separator.."]+") do
		table.insert(Parts, z)
	end
	
	if UnpackResults then
		return unpack(Parts)
	end
	
	return Parts
end

function CheckArg(FuncName, ArgNum, Arg, Types)
	--[[if not Cache.CheckArg then
		Cache.CheckArg = {}
	end
	local oK = tostring(FuncName) .. "/" .. tostring(ArgNum) .. "/" .. tostring(Arg) .. "/" .. tostring(Types) .. "/"
	if Cache.CheckArg[oK] and CacheEnabled then
		return Cache.CheckArg[oK][1]
	end]]
	
	local Type = framework:Type(Arg):lower()
	if Types:find("/") then
		local TypesList = SeparateString(Types, "/")
	
		for _,v in pairs(TypesList) do
			local ClassName
			if v:sub(0,9) == "instance:" then
				local Parts = SeparateString(v, ":")
	
				ClassName = Parts[2]
			end
	
			if Type == v then
				--Cache.CheckArg[oK] = {true, tick()}
				return true
			elseif Type == "instance" and v:sub(0,8) == "instance" and ClassName and Arg:IsA(ClassName) then
				--Cache.CheckArg[oK] = {true, tick()}
				return true
			end
		end
	else
		if Types:find(":") then
			local ClassName
			if Types:sub(0,9) == "instance:" then
				local Parts = SeparateString(Types, ":")
	
				ClassName = Parts[2]
			end
			
			if Type == "instance" and Types:sub(0,8) == "instance" and ClassName and Arg:IsA(ClassName) then
				return true
			end
		else
			if Type == Types then
				return true
			end
		end
	end

	error("bad argument #"..ArgNum.." to 'framework:"..FuncName.."' ("..Types.." expected, got "..Type..")", 0)
end


-- Create the metatable.
framework = setmetatable({}, {
	__index = function(self, i)
		output("The index '" .. i .. "' does not exist! Check the Documentation in the Xeptix Framework Plugin for a list of all our features/functions.", 2)
	end,
	__newindex = function(self, i, v)
		if _G.frameworkready then
			output("Editing the framework is prohibited for security purposes!", 2)
		else
			rawset(self, i, v)
		end
	end,
	__call = function(self)
		return 69 * 420.58441613588 * 682.60869565217 * 2
	end,
	__metatable = script,
	__tostring = function(self)
		return Version
	end
})

_G.premature_framework = framework -- for libraries to use the framework before it is 100% loaded
framework.Settings = Settings


local premature_events, premature_functions = {}, {} -- just gonna stick this here :P
function framework:AddEvent(...)
	table.insert(premature_events, {...})
end

function framework:AddFunction(...)
	table.insert(premature_functions, {...})
end


-- Core API
function framework:internalrequest(Key, Req, ...)
	if Key == "42069" and Req then
		if Req == "DCRequest" then
			return DCRequest(...)
		end
	end
end

function framework:IsLocal()
	return game:GetService("RunService"):IsClient()
end

function framework:IsMobile()
	if not framework:IsLocal() then
		output("Whoops! framework::IsMobile() only works on the client!", 2)
	end
	
	return game:GetService("UserInputService").TouchEnabled
end

function framework:CreateSignal()
	return NewSignal()
end

function framework:Recursive(Object, Callback)
	local WaitEvery = 250
	local NextWait = WaitEvery
	local function Recursive(Parent)
		for _,v in pairs(Parent:GetChildren()) do
			NextWait = NextWait - 1
			if NextWait <= 0 then
				NextWait = WaitEvery
				wait()
			end
			
			Callback(v)

			Recursive(v)
		end
	end

	Recursive(Object)
end


function framework:Type(x)
	return typeof(x)
	
	--[[
	if not Cache.Types then Cache.Types = {} end
	if Cache.Types[tostring(x)] and CacheEnabled then return Cache.Types[tostring(x)][1] end
	
	local lol = tostring(x) -- saftey first bro!
	local T = type(x)

	if T ~= "userdata" then
		return T:lower()
	else
		local TestFor = {}

		TestFor.Vector2 = function()
			local succ, zex = pcall(function() -- test for Z (fix for mistaking Vector3's for Vector2's)
				return x.z ~= nil
			end)
			
			return x.x and x.y and x.unit and x.magnitude and not succ and not tonumber(zex)
		end
		TestFor.Vector3 = function()
			return x.X and x.Y and x.Z and x.Unit and x.Magnitude
		end
		TestFor.CFrame = function()
			return x.p and x.X and x.Y and x.Z and x.lookVector
		end
		TestFor.UDim2 = function()
			return x.X and x.Y and x.X.Scale and x.X.Offset and x.Y.Scale and x.Y.Offset
		end
		TestFor.Color3 = function()
			return x.r and x.g and x.b
		end
		TestFor.BrickColor = function()
			return x.r and x.g and x.b and x.Number and x.Name and x.Color
		end
		TestFor.Enum = function()
			return tostring(x):sub(0,4) == "Enum" or Enum[tostring(x)]
		end
		TestFor.Instance = function()
			return x.ClassName and x.Name and x.Archivable ~= nil
		end

		for _,v in pairs(TestFor) do
			local Pass1, Pass2 = pcall(v)
			if Pass1 and Pass2 then
				Cache.Types[lol] = {_:lower(), tick()}
				return _:lower()
			end
		end
	end
	
	return "userdata" -- yup]]
end

function framework:EncodeJSON(input)
	if type(input) == "string" then return input end
	--if not Cache.EJSON then Cache.EJSON = {} end
	--if Cache.EJSON[input] and CacheEnabled then return Cache.EJSON[input][1] end
	local r = HttpService:JSONEncode(input)
	--Cache.EJSON[input] = {r, tick() - (60 * 0.75)}
	return r
end

function framework:JSONEncode(input)
	return framework:EncodeJSON(input)
end

function framework:DecodeJSON(input)
	if type(input) == "table" then return input end
	--if not Cache.DJSON then Cache.DJSON = {} end
	--if Cache.DJSON[input] and CacheEnabled then return Cache.DJSON[input][1] end
	local r = HttpService:JSONDecode(input)
	--Cache.DJSON[input] = {r, tick() - (60 * 0.75)}
	return r
end

function framework:JSONDecode(input)
	return framework:DecodeJSON(input)
end


framework.OnClose = NewSignal()
local Success, Error = pcall(function()
	game.OnClose = function(...)
		framework.OnClose:fire(...)
		
		-- all the players are kicked now, and no new ones can join, might as well let the server finish doing its thaaang
		wait(27.5) -- will wait almost 30 seconds (the timeout) to ensure any short operations finish
	end
end)

if not Success then
	output("An error has occurred while assigning game.OnClose, another script has already set the callback. The framework/your game may not function properly! Please use the framework.OnClose event instead!", 3)
end


if not framework:IsLocal() then
	AdminList = Instance.new("StringValue")
	AdminList.Value = "[]"
	AdminList.Name = "[Admin List]"
	AdminList.Parent = Stuff

	BannedList = Instance.new("StringValue")
	BannedList.Value = "[]"
	BannedList.Name = "[Banned List]"
	BannedList.Parent = Stuff
end


-- DevCircle Connection
Connected = false
DevCircle_Keys = {Public = nil, Private = nil, Game = nil} -- These are the 3 verification keys that permit access to THIS GAMES online database.
local DatabasesDisabled, LeaderboardsDisabled, CommunicationDisabled,ErrorsDisabled = false, false,false,false

if Vars:findFirstChild("DCK") and not game:GetService("RunService"):IsStudio() then
	Connected = true
	DevCircle_Keys.DCK_Public = Vars.DCK.PUB.Value
	DevCircle_Keys.DCK_Private = Vars.DCK.PRIV.Value
	DevCircle_Keys.DCK_Game = Vars.DCK.GM.Value
end

framework.DCC = Connected


function DCRequest(URL, Type, X)
	-- if Type (lower) is "get", X is null
	-- if Type (lower) is "post", X is the table of data to post with PostAsync
	
	URL = "http://api.devcircle.net/roblox/" .. URL .. "?JobID=" .. game.JobId .. "&PlaceID=" .. game.PlaceId .. "&CreatorID=" .. game.CreatorId .. "&PlaceVersion=" .. game.PlaceVersion .. "&FRV=" .. Version
	if Type:lower() == "get" then
		local Success, Result = pcall(function() return HttpService:PostAsync(URL, HttpService:JSONEncode(DevCircle_Keys)) end)
	
		if Success then
			return Result
		else
			return "!error"
		end
	elseif Type:lower() == "post" then
		for _,v in pairs(DevCircle_Keys) do -- add the keys to the request
			X[_] = v
		end
		
		local Data = HttpService:JSONEncode(X)
		
		
		local Success, Result = pcall(function() return HttpService:PostAsync(URL, Data) end)
		
		if Success then
			return Result
		else
			return "!error"
		end
	else
		output("An error occured.", 2)
	end
end


-- DevCircle API & DC Related Code
local ErrorsToSubmit = {}
function SubmitError(Message, Line, Script)
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if ErrorsDisabled then
		return
	end
	
	table.insert(ErrorsToSubmit, {Message = Message, Line = Line, Script = Script})
end

function SubmitXFError(Message, Line)
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if ErrorsDisabled then
		return
	end
	
	table.insert(ErrorsToSubmit, {Message = Message, Line = Line, FrameworkError = true})
end


--[[DatabaseCache = {} -- we'll set up a task to loop through the indexes every 10 seconds, updating each. (it should do this by setting the cache to {}, then calling FetchDatabase on each of the previous keys.
DatabaseKeyEditCache = {} -- ["Database"] = {["Key"] = Timestamp} <-- to keep track of when each key was edited
DatabaseFetching = {}
function framework:FetchDatabase(DatabaseName, forceRefresh)
	CheckArg("FetchDatabase", 1, DatabaseName, "string")
	
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return output("framework::FetchDatabase() can only be fired from the server!", 2)
	end
	
	if DatabasesDisabled then return end
	
	-- once a database is fetched the 1st time, it updates every minute (it saves, which auto fetches)
	-- this just returns the cached version
	
	-- when saving, the server should automatically save the value if it was modified after
	-- ex: if this server sets X to 1, then 2 seconds later a different server sets X to 2, when the cache updates, X will be 2 in both, because it was last changed
	
	if DatabaseFetching[DatabaseName] and not forceRefresh then
		repeat wait() until not DatabaseFetching[DatabaseName]
	end
	
	if DatabaseCache[DatabaseName] and not forceRefresh then
		return DatabaseCache[DatabaseName]
	end
	
	-- fetch entire database from server, cache it, return it
	local Database = DCRequest("database/get", "post", {Name = DatabaseName, Timestamp = tick()})
	if Database == "disabled" then
		DatabasesDisabled = true
		return
	end
	
	if Database == "404" then
		-- Internal server error?
		-- When a database 404's, it should automatically create a blank database
	else
		local Success, JSON = pcall(function()
			return HttpService:JSONDecode(Database)
		end)
		
		if Success and type(JSON) == "table" then
			local function makeValue(v, t)
				if t == 'string' then
					return v
				elseif t == 'number' then
					return tonumber(v)
				elseif t == 'table' then
					return framework:DecodeJSON(v)
				elseif t == 'boolean' then
					return v == 'true' and true or false
				elseif t == 'color3' then
					local x = SeparateString(v, ", ")
					return Color3.new(unpack(x))
				elseif t == 'vector3' then
					local x = SeparateString(v, ", ")
					return Vector3.new(unpack(x))
				elseif t == 'vector2' then
					local x = SeparateString(v, ", ")
					return Vector2.new(unpack(x))
				elseif t == 'cframe' then
					local x = SeparateString(v, ", ")
					return CFrame.new(unpack(x))
				elseif t == 'brickcolor' then
					return BrickColor.new(v)
				elseif t == 'nil' then
					return nil
				else
					return v
				end
			end
			
			if DatabaseCache[DatabaseName] then
				-- it is UPDATING the database, no need to re-create the metatable, just update the _raw value.
				DatabaseCache[DatabaseName]._raw = {}
				for k,v in pairs(JSON) do
					DatabaseCache[DatabaseName]._raw[k] = makeValue(v['Value'], v['ValueType'])
				end
				
				return DatabaseCache[DatabaseName]
			end
			
			
			local DatabaseF = {_raw = {}}
			for k,v in pairs(JSON) do
				DatabaseF._raw[k] = makeValue(v['Value'], v['ValueType'])
			end
			
			function DatabaseF:raw(reallyRaw)
				if reallyRaw then
					return DatabaseCache[DatabaseName]._raw
				end
				
				local raw = {}
				for k,v in pairs(DatabaseCache[DatabaseName]._raw) do
					raw[k] = {Value = tostring(v), ValueType = framework:Type(v)}
				end
				
				return raw
			end
			function DatabaseF:Get(Key)
				return DatabaseCache[DatabaseName]._raw[Key]
			end
			function DatabaseF:Set(Key, Value)
				DatabaseCache[DatabaseName]._raw[Key] = Value
				if not DatabaseKeyEditCache[DatabaseName] then
					DatabaseKeyEditCache[DatabaseName] = {}
				end
				
				DatabaseKeyEditCache[DatabaseName][Key] = tick()
			end
			
			Database = setmetatable(DatabaseF, {
				__index = function(self, i)
					output("An error occured. Please read the documentation on Online Databases!", 2)
				end,
				__newindex = function(self, i, v)
					output("In order to save content to the database, you must use Database::Set!", 1)
				end,
				__metatable = false,
				__tostring = Database
			})
			
			DatabaseCache[DatabaseName] = Database
			return Database
		end
	end
	
	output("An internal server error occured while fetching the database \"" .. DatabaseName .. "\"!", 3)
end

function SaveDatabase(DatabaseName)
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return output("framework::SaveDatabase() can only be fired from the server!", 2)
	end
	
	if DatabasesDisabled then return end
	
	-- Compile a list of all the keys that were edited (using DatabaseKeyEditCache), send that along with the entire cached database to the server. The server can figure out the rest.
	local EditKeys = DatabaseKeyEditCache[DatabaseName] or {}
	DCRequest("database/set", "post", {Name = DatabaseName, Timestamp = tick(), StartTimestamp = start, Database = DatabaseCache[DatabaseName]:raw(), EditKeys = EditKeys})
	
	-- After the save completed:
	DatabaseFetching[DatabaseName] = true
	
	framework:FetchDatabase(DatabaseName, true) -- to refresh the cache for the database
	
	DatabaseFetching[DatabaseName] = false
end]] 


function framework:SaveDataToDC(UserID, Data)
	-- this is how we'll make userdata storage without database support (roblox y u do dis 2 meeee)
	if DatabasesDisabled then return end
	local result = DCRequest("database/setV2", "post", {UserID = UserID, Data = Data, Timestamp = tick()})
	if result == "disabled" then
		DatabasesDisabled = true
	end
end


local ServerData = {Started = start, Tick = tick(), PlayerLog = {}, TotalPlayers = 0, TotalUniquePlayers = 0, TotalPlaytime = 0, Errors = 0, Output = {}, Sales = 0, RobuxEarned = 0, CachedItemsCleared = 0}
function Communicate(x)
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return output("framework::Communicate() can only be fired from the server!", 2)
	end
	
	ServerData.Tick = tick()
	if CommunicationDisabled then return end
	
	-- for communicating with the server. Communication occures every 3 seconds.
	-- Basically, the server sends data, we send data in return.
	-- The server processes data we send, we process data the server sends.
		-- his is how we keep server info up to date (outgoing), and manage the server online (incoming)

	local Data = {ServerData = {}, Players = {}}
	
	if x == 1337 then
		ServerData.ServerDied = true
	end
	
	for _,v in pairs(ServerData) do
		Data.ServerData[_] = v
	end
	for _,v in pairs(game.Players:GetPlayers()) do
		local D = framework:GetData(v)
		if D then
			D = D.dataSet
		else
			D = {DataNull = true}
		end
		
		local Log = nil
		for _,v in pairs(ServerData.PlayerLog) do
			if v.UserID == v.userId and v.ExitTime == 0 then
				Log = v
			end
		end
		
		table.insert(Data.Players, {ID = v.userId, Name = v.Name, LogData = Log})
	end
	-- "Data" is what we send TO the server.
	-- We must then proccess what it sends in return.
	local ReturnData = DCRequest("communication", "post", {Timestamp = tick(), Data = Data})
	if ReturnData == "disabled" then
		CommunicationDisabled = true
		return
	end
	
	if ReturnData ~= "404" then
		local Success, JSON = pcall(function()
			return HttpService:JSONDecode(ReturnData)
		end)
		
		if Success and type(JSON) == "table" then
			local Meh
			Meh = function()
				for _,v in pairs(ServerData.PlayerLog) do
					if v.ExitTime ~= 0 then
						table.remove(ServerData.PlayerLog, _)
						
						return Meh()
					end
				end
			end
			
			Meh()
			
			if JSON.KickUsers then
				for _,v in pairs(JSON.KickUsers) do
					local Player = game.Players:GetPlayerByUserId(_)
					if Player then
						framework:Kick(Player, v)
					end
				end
			elseif JSON.BanUsers then -- does not have to be in server
				for _,v in pairs(JSON.BanUsers) do
					framework:Ban(_, v.Message, v.Duration)
				end
			elseif JSON.UnbanUsers then -- does not have to be in server
				for _,v in pairs(JSON.UnbanUsers) do
					framework:Unban(_)
				end
			elseif JSON.SetData then -- does not have to be in server
				for _,v in pairs(JSON.KickUsers) do
					local D = framework:LoadData(_)
					if D then
						D:Set(v.Key, v.Value)
					end
				end
			elseif JSON.Shutdown then -- they requested to shut the server down from the website
				game.Players.PlayerAdded:connect(function(Player)
					Player:Kick()
				end)
				
				for _,v in pairs(game.Players:GetPlayers()) do
					v:Kick()
				end
				
				delay(60.42069, function() while true do end end) -- if it lasts 1 minute, take it down the hard way >.>
			end
			
			return JSON.WaitTime
		end
	end
end


if Connected then
	game.Players.PlayerAdded:connect(function(Player)
		local isInList = false
		for _,v in pairs(ServerData.PlayerLog) do
			if v.UserID == Player.userId then
				isInList = true
				break
			end
		end
		
		ServerData.TotalPlayers = ServerData.TotalPlayers + 1
		if not isInList then
			ServerData.TotalUniquePlayers = ServerData.TotalUniquePlayers + 1
		end
		
		table.insert(ServerData.PlayerLog, {
			UserID = Player.userId,
			Username = Player.Name,
			EnterTime = tick(),
			ExitTime = 0
		})
	end)
	
	game.Players.PlayerRemoving:connect(function(Player)
		local tbl, tbli
		for _,v in pairs(ServerData.PlayerLog) do
			if v.UserID == Player.userId and v.ExitTime == 0 then
				tbl = v
				tbli = _
				break
			end
		end
		
		if tbl and tbli then
			local Playtime = tick() - tbl.EnterTime
			
			tbl.ExitTime = tick()
			ServerData.PlayerLog[tbli] = tbl
			
			ServerData.TotalPlaytime = ServerData.TotalPlaytime + Playtime
		end
	end)

	game:GetService("LogService").MessageOut:connect(function(Message, Type)
		--[[table.insert(ServerData.Output, {
			Timestamp = tick(),
			Message = Message,
			Type = tostring(Type)
		})]]
		
		if Type == Enum.MessageType.MessageError then
			local Local = framework:IsLocal()
			local Pos = Message:find(":") or 1
			local ErrorScript = Message:sub(0, Pos - 1)
			
			local X = Message:sub(Pos + 1)
			local Pos2 = X:find(":") or 1
			
			local ErrorLine = X:sub(0, Pos2 - 1)
			local Error = X:sub(Pos2 + 1)
			
			ServerData.Errors = ServerData.Errors + 1
			
			if ErrorScript == script:GetFullName() then
				-- if the error was a framework error, report it regardless of DC connection.
				-- the server automatically filters out anything people manually add by abusing the URL.
				SubmitXFError(Error, ErrorLine)
				--warn("Framework Error!\nS: " .. ErrorScript .. "\nL: " .. ErrorLine .. "\nE: " .. Error)
			elseif Connected and ErrorScript:find(".") then
				-- If the error wasn't a framework error, and the game is connected, report it.
				local Pos3 = 1 -- :find was not working out too great.... hm....
				for i = 1, #ErrorScript do
					if ErrorScript:sub(i, i) == "." then
						Pos3 = i
					end
				end
				
				local FullNamePart1 = ErrorScript:sub(0, Pos3 - 1)
				
				if game:findFirstChild(FullNamePart1, true) then -- check if it was a script error.
					-- it was a script error, submit it as such	
					SubmitError(Error, ErrorLine, ErrorScript)	
					--warn("\n\nOther Script Error!\nS: " .. ErrorScript .. "\nL: " .. ErrorLine .. "\nE: " .. Error .. "\n\n")
				else
					-- it was a misc. error, submit it as such (submit Message)
					SubmitError(Error, "Unknown", ErrorScript)
					--warn("\t'" .. FullNamePart1 .. "'\t'" .. ErrorScript .. "' \t")
				end	
			end
		end
	end)
end


if not framework:IsLocal() and Connected then
	-- Communicate/Database Tasks
	
	--[[function DBTask(x)
		for k,v in pairs(DatabaseCache) do
			spawn(function()
				SaveDatabase(k)
			end)
		end
		
		if x == 1337 then return end
		wait(30)
		DBTask()
	end
	
	spawn(DBTask)]]
	
	
	
	function CommunicateTask(x)
		local wt = Communicate(x)
		if not wt or type(wt) ~= "number" then wt = 20 end
		
		
		if x == 1337 then return end
		wait(wt)
		CommunicateTask()
	end
	
	spawn(CommunicateTask)
	
	
	
	function ErrorsTask(x)
		if not ErrorsDisabled then
			local msg = DCRequest("error", "post", {Errors = ErrorsToSubmit})
			if msg == "disabled" then
				ErrorsDisabled = true
			end
		end
		
		ErrorsToSubmit = {}
		if x == 1337 then return end
		wait(60)
		ErrorsTask()
	end
	
	spawn(ErrorsToSubmit)
	
	
	
	framework.OnClose:connect(function()
		--pcall(function() DBTask(1337) end)
		pcall(function() CommunicateTask(1337) end)
		pcall(function() ErrorsTask(1337) end)
	end)
end


-- CI Additional Code
if not framework:IsLocal() then
	framework:AddFunction("XeptixFramework/GetServerStats", function()
		local x = {}
		table.insert(x, {"Uptime:", framework:TimeToString(tick() - ServerData.Started)})
		table.insert(x, {"# Players:", game.Players.NumPlayers})
		table.insert(x, {"# Visits:", ServerData.TotalPlayers})
		table.insert(x, {"# Unique Visits:", ServerData.TotalUniquePlayers})
		table.insert(x, {"Time Spent In Server:", framework:TimeToString(ServerData.TotalPlaytime)})
		table.insert(x, {"Avg. Playtime:", framework:TimeToString(ServerData.TotalPlaytime / ServerData.TotalPlayers)})
		table.insert(x, {"# Errors:", ServerData.Errors})
		table.insert(x, {"# Sales:", ServerData.Sales})
		table.insert(x, {"Robux Earned:", ServerData.RobuxEarned})
		table.insert(x, {"Avg. Income Per Sale:", math.floor(ServerData.RobuxEarned / ServerData.Sales)})
		
		return x
	end)
end


-- String API
function framework:SeparateString(String, Separator, UnpackResults)
	CheckArg("SeparateString", 1, String, "string")
	CheckArg("SeparateString", 2, Separator, "string")

	return SeparateString(String, Separator, UnpackResults)
end


-- Table API
function framework:ShuffleTable(Table)
	CheckArg("ShuffleTable", 1, Table, "table")

	local Shuffled = {}
	local Duplicate = framework:DuplicateTable(Table)
	
	while framework:IndexCount(Duplicate) > 0 do
		local function GetRandom()
			for _,v in pairs(Duplicate) do
				local R = math.random(25)
				if R == 1 or R == 25 then
					return _, v
				end
			end
			
			
			return GetRandom()
		end
		
		local index, value = GetRandom()
		if type(index) == "number" then
			table.insert(Shuffled, value)
		else
			Shuffled[index] = value
		end
		
		Duplicate = framework:RemoveIndexFromTable(Duplicate, index)
	end

	return Shuffled
end

function framework:DuplicateTable(Table)
	CheckArg("DuplicateTable", 1, Table, "table")

	local Duplicate = {}

	for _, v in pairs(Table) do
		Duplicate[_] = v
	end

	return Duplicate
end

function framework:RemoveIndexFromTable(Table, Index)
	CheckArg("RemoveIndexFromTable", 1, Table, "table")

	local New = {}

	for _,v in pairs(Table) do
		if _ ~= Index then
			New[_] = v
		end
	end

	return New
end

function framework:RemoveValueFromTable(Table, Value)
	CheckArg("RemoveValueFromTable", 1, Table, "table")

	local New = {}

	for _,v in pairs(Table) do
		if v ~= Value then
			New[_] = v
		end
	end

	return New
end

function framework:IndexCount(Table)
	CheckArg("IndexCount", 1, Table, "table")

	local Count = 0

	for _,v in pairs(Table) do
		Count = Count + 1
	end

	return Count
end

function framework:ValueExistsInTable(Table, Value)
	CheckArg("ValueExistsInTable", 1, Table, "table")

	for _,v in pairs(Table) do
		if v == Value then
			return true
		else -- should we do this? I think yes.
			if type(Value) == "number" and type(v) == "string" then
				if tonumber(v) == Value then
					return true
				end
			end
		end
	end

	return false
end


-- Number API
function framework:RoundNumber(Number, Nearest)
	CheckArg("RoundNumber", 1, Number, "number")

	if not Nearest then
		Nearest = 1 -- if you don't supply round to nearest whole number
	end
	
	if Nearest ~= 1 then
		error("Currently, you can only round to the decimal... Sorry!")
	end
	
	-- figure out this math stuff later in order to make Nearest argument work
	
	local Floor = math.floor(Number)
	
	if Number < Floor + (Nearest / 2) then
		Number = math.floor(Number / Nearest) * Nearest
	else
		Number = math.ceil(Number / Nearest) * Nearest
	end
	
	return Number
end

function framework:FormatNumber(Number, AD)
	CheckArg("FormatNumber", 1, Number, "number")
	CheckArg("FormatNumber", 2, AD, "nil/boolean")
	if not Cache.NWC then Cache.NWC = {} end
	
	local D = ""
	Number = tonumber(tostring(Number)) or (Number > 2147483247 and 2147483247 or (Number < -2147483247 and -2147483247 or 0))
	if not AD then
		Number = math.floor(Number)
	else
		D = tostring(Number-math.floor(Number)):sub(2)
		Number = math.floor(Number)
	end
	
	if Cache.NWC[tostring(Number)..tostring(AD)] and CacheEnabled then return Cache.NWC[tostring(Number)..tostring(AD)][1] end
	local oR = tostring(Number)..tostring(AD)
	
	local Neg
	if Number < 0 then
		Neg = true
		Number = -Number
	end

	local Str = ""
	local StrN = tostring(Number)

	local x = 0
	for i = #StrN, 1, -1 do
		Str = Str .. StrN:sub(i, i)

		x = x + 1
		if x == 3 and i > 1 then
			x = 0

			Str = Str .. ","
		end
	end

	local lol = (Neg and "-" or "") .. Str:reverse() .. D
	Cache.NWC[oR] = {lol, tick()}
	return lol
end

function framework:NumberWithCommas(Number, AllowDecimals)
	CheckArg("NumberWithCommas", 1, Number, "number")
	
	return framework:FormatNumber(Number, AllowDecimals)
end

function framework:AbbreviateNumber(number)
	CheckArg("AbbreviateNumber", 1, number, "number")
	
	if not Cache.Abbrv then
		Cache.Abbrv = {}
	end
	
	
	local oN = tostring(math.floor(number))
	if Cache.Abbrv[oN] and CacheEnabled then return Cache.Abbrv[oN][1] end
	-- bad coding is bad! fix this up eventually
	local abrv = ""
	local a
	number = math.floor(number)
	local neg = number < 0
	if neg then
		number = -number
	end
	local x = #tostring(number)
	
	if x > 10 then
		a = "B+"
		x = x-10
	elseif number >= 1000000000 then
		a = "B+"
		if number >= 100000000000 then
			x = 3
		elseif number >= 10000000000 then
			x = 2
		else
			x = 1
		end
	elseif number >= 1000000 then
		a = "M+"
		if number >= 100000000 then
			x = 3
		elseif number >= 10000000 then
			x = 2
		else
			x = 1
		end
	elseif number >= 1000 then
		a = "K+"
		if number >= 100000 then
			x = 3
		elseif number >= 10000 then
			x = 2
		else
			x = 1
		end
	end
	
	if neg then
		number = -number
		if x then
			x = x + 1
		end
	end
	
	if a and x then
		abrv = tostring(number):sub(0,x) .. a
	else
		abrv = tostring(number)
	end
	
	Cache.Abbrv[oN] = {abrv, tick()}
	return abrv
end


-- Part API
function framework:TweenPart(...) -- DEPRECATED
	return framework:TweenPartPosition(...)
end

function framework:TweenPartPosition(part, endPosition, dir, style, time)
	CheckArg("TweenPartPosition", 1, part, "instance:BasePart")
	CheckArg("TweenPartPosition", 2, endPosition, "vector3")
	--CheckArg("TweenPartPosition", 3, dir, "Enum.EasingDirection/string")
	--CheckArg("TweenPartPosition", 4, style, "Enum.EasingStyle/string")
	--CheckArg("TweenPartPosition", 5, time, "number")

	if not time then
		time = 3
	end

    local frameXZ,frameY  = Instance.new("Frame",workspace.Terrain),Instance.new("Frame",workspace.Terrain)
    
	frameXZ.Position = UDim2.new(part.Position.X, 0, part.Position.Z, 0)
    frameY.Position = UDim2.new(0, 0, part.Position.Y, 0)

    frameXZ:TweenPosition(UDim2.new(endPosition.X, 0, endPosition.Z, 0), dir, style, time+.5, true)
    frameY:TweenPosition(UDim2.new(0, 0, endPosition.Y, 0), dir, style, time+.5, true)

    local t = tick()
    while wait() do
		local posx,posy = frameXZ.Position,frameY.Position
		part.CFrame = CFrame.new(Vector3.new(posx.X.Scale, posy.Y.Scale, posx.Y.Scale)) * CFrame.Angles(framework:GetRotation(part))
		
		if tick() - t >= time + .5 then
            break
        end
    end

    part.CFrame = CFrame.new(endPosition) * CFrame.Angles(framework:GetRotation(part))

    frameXZ:Destroy()
    frameY:Destroy()
end

function framework:TweenPartSize(part, endSize, dir, style, time)
	CheckArg("TweenPartSize", 1, part, "instance:BasePart")
	CheckArg("TweenPartSize", 2, endSize, "vector3")
	--CheckArg("TweenPartSize", 3, dir, "Enum.EasingDirection/string")
	--CheckArg("TweenPartSize", 4, style, "Enum.EasingStyle/string")
	--CheckArg("TweenPartSize", 5, time, "number")

	if not time then
		time = 3
	end

    local frameXZ,frameY  = Instance.new("Frame",workspace.Terrain),Instance.new("Frame",workspace.Terrain)
    
	frameXZ.Size = UDim2.new(part.Size.X, 0, part.Size.Z, 0)
    frameY.Size = UDim2.new(0, 0, part.Size.Y, 0)

    frameXZ:TweenSize(UDim2.new(endSize.X, 0, endSize.Z, 0), dir, style, time+.5)
    frameY:TweenSize(UDim2.new(0, 0, endSize.Y, 0), dir, style, time+.5)

    local t = tick()
    while wait() do
		local posx,posy = frameXZ.Size,frameY.Size
		part.Size = Vector3.new(posx.X.Scale, posy.Y.Scale, posx.Y.Scale)
		
		if tick() - t >= time + .5 then
            break
        end
    end

    part.Size = endSize

    frameXZ:Destroy()
    frameY:Destroy()
end

function framework:GetCFrame(Model)
	CheckArg("GetCFrame", 1, Model, "instance:BasePart/instance:Model")

	if Model:IsA("BasePart") then
		return Model.CFrame
	end

	return Model:GetModelCFrame()
end

function framework:GetRotation(Model)
	CheckArg("GetRotation", 1, Model, "instance:BasePart/instance:Model")

	if Model:IsA("BasePart") then
		return Model.CFrame:toEulerAnglesXYZ()
	end

	return framework:GetCFrame(Model):toEulerAnglesXYZ()
end

function framework:SetCFrame(Model, CF, NewCFrame)
	CheckArg("SetCFrame", 1, Model, "instance:BasePart/instance:Model")
	CheckArg("SetCFrame", 2, CF, "cframe")
	CheckArg("SetCFrame", 3, NewCFrame, "boolean")

	if Model:IsA("BasePart") then
		if not NewCFrame then
			Model.CFrame = Model.CFrame * CF
			return
		end

		Model.CFrame = CF
		return
	end


	-- check if the model has a PrimaryPart, otherwise make a temp one
	local Primary, Temp
	
	if Model.PrimaryPart then
		Primary = Model.PrimaryPart
	else
		Temp = true

		Primary = Instance.new("Part")
		Primary.Name = "PrimaryPart"
		Primary.Transparency = 1
		Primary.Anchored = true
		Primary.CanCollide = false
		Primary.Size = Model:GetModelSize()
		Primary.CFrame = Model:GetModelCFrame()

		Primary.Parent = Model
		Model.PrimaryPart = Primary
	end

	Model:SetPrimaryPartCFrame(CF)
	if Temp then
		Primary:Destroy()
	end
end

function framework:SetRotation(Model, Rotation, Increment) -- todo: remake this...
	CheckArg("SetRotation", 1, Model, "instance:BasePart/instance:Model")
	CheckArg("SetRotation", 2, Rotation, "cframe")

	local cf = framework:GetCFrame(Model)
	local x, y, z = cf:toEulerAnglesXYZ()
	local x2, y2, z2 = Rotation:toEulerAnglesXYZ()
	local newRotationX, newRotationY, newRotationZ =
		(Increment and x or 0) + math.rad(x2 or 0),
		(Increment and y or 0) + math.rad(y2 or 0),
		(Increment and z or 0) + math.rad(z2 or 0)

	return framework:SetCFrame(Model, cf * CFrame.Angles(newRotationX, newRotationY, newRotationZ), true)
end


-- Gui API
local AutosizeCanvases = {}
function framework:AutosizeCanvas(ScrollingFrame, paddingOverride)
	CheckArg("AutosizeCanvas", 1, ScrollingFrame, "instance:ScrollingFrame")

	if AutosizeCanvases[ScrollingFrame] then return end
	AutosizeCanvases[ScrollingFrame] = true
	ScrollingFrame.Changed:connect(function(Prop)
		if Prop == "Parent" and not ScrollingFrame.Parent then
			AutosizeCanvases[ScrollingFrame] = nil
		end
	end)
	
	local padding = 0
	
	if not paddingOverride then
		paddingOverride = padding
	end
	
	local nextUpdate, alreadyUpdatingAgain, updateDelay = 0, false, 0.5
	local function UpdateSize()
		if nextUpdate >= tick() then -- HUGE lag fix ;)
			if not alreadyUpdatingAgain then
				alreadyUpdatingAgain = true
				delay(updateDelay, UpdateSize)
			end
			
			return
		end
		
		alreadyUpdatingAgain = false
		nextUpdate = tick() + updateDelay
		
		local CanvasSizeX, CanvasSizeY = 0, 0
		
		local function Recursive(Parent)
			for _,v in pairs(Parent:GetChildren())do
				--Recursive(v)

				if v:IsA("GuiObject") then
					local BottomPosition, RightPosition = 
						((v.Position.Y.Scale * v.Parent.AbsoluteSize.Y) + v.Position.Y.Offset) + 
						((v.Size.Y.Scale * v.Parent.AbsoluteSize.Y) + v.Size.Y.Offset),
						((v.Position.X.Scale * v.Parent.AbsoluteSize.X) + v.Position.X.Offset) +
						((v.Size.X.Scale * v.Parent.AbsoluteSize.X) + v.Size.X.Offset)
						
					if BottomPosition > CanvasSizeY then
						CanvasSizeY = BottomPosition
					end
					
					if RightPosition > CanvasSizeX then
						CanvasSizeX = RightPosition
					end
				end
			end
		end

		Recursive(ScrollingFrame)
		
		local CanvasPosition = ScrollingFrame.CanvasPosition
		ScrollingFrame.CanvasSize = UDim2.new(0, CanvasSizeX + paddingOverride, 0, CanvasSizeY + paddingOverride)
		ScrollingFrame.CanvasPosition = CanvasPosition
	end
	
	ScrollingFrame.ChildAdded:connect(function(Child)
		if Child:IsA("GuiObject") then
			UpdateSize()
			
			Child.Changed:connect(function(prop)
				if prop == "Position" or prop == "Size" then
					UpdateSize()
				end
			end)
		end
	end)
	ScrollingFrame.ChildRemoved:connect(function(Child)
		if Child:IsA("GuiObject") then
			UpdateSize()
		end
	end)
	
	ScrollingFrame.Changed:connect(function(prop)
		if prop == "Position" or prop == "Size" then -- we dont want to spam this every time you scroll
			UpdateSize()
		end
	end)
	
	UpdateSize()
end

local ThreeDLib = require(Libs.Module3d)
function framework:Gui3d(a, b, r) -- r = rotation enabled, by default true
	CheckArg("Gui3d", 1, a, "instance:GuiObect")
	CheckArg("Gui3d", 2, b, "instance:BasePart")

	local ThreeD = ThreeDLib:Attach3D(a, b)
	ThreeD:SetActive(true)
	
	if r == nil then
		r = true
	end
	
	local Con
	Con = game:GetService("RunService").RenderStepped:connect(function() -- 60 FPS
		if not ThreeD or not ThreeD.Object3D or not r then -- stop the loop
			Con:disconnect()
			
			return
		end
		
		local fullRotation = math.pi*2 --360 degrees in radians
		local currentRotation = tick()%fullRotation
		ThreeD:SetCFrame(CFrame.Angles(0,currentRotation,0))
	end)
	
	return ThreeD
end


-- Collision API
function framework:GetColliding(Object, IgnoreList)
	CheckArg("GetColliding", 1, Object, "instance:Model/instance:BasePart/instance:GuiObject")

	if type(IgnoreList) ~= "table" then
		IgnoreList = {Object}
	else
		table.insert(IgnoreList, Object)
	end

	if Object:IsA("GuiObject") then
		-- Get all of the GuiObjects (Frames, buttons, labels, images, etc)
		local Parent = Object
		repeat
			Parent = Parent.Parent
		until Parent:IsA("ScreenGui") or Parent:IsA("SurfaceGui") or Parent:IsA("BillboardGui") or Parent == game
		
		if Parent ~= game then
			Parent = Parent.Parent
		end


		local GuiObjects = {}
		framework:Recursive(Parent, function(o)
			if o:IsA("GuiObject") and o ~= Object and not framework:ValueExistsInTable(IgnoreList, o) then
				table.insert(GuiObjects, o)
			end
		end)

		
		-- Collision checking
		local Colliding = {}

		for _,v in pairs(GuiObjects) do
			local gui1, gui2 = Object, v
			local C = ((gui1.AbsolutePosition.X < gui2.AbsolutePosition.X + gui2.AbsoluteSize.X and gui1.AbsolutePosition.X + gui1.AbsoluteSize.X > gui2.AbsolutePosition.X) and (gui1.AbsolutePosition.Y > gui2.AbsolutePosition.Y and gui1.AbsolutePosition.Y < gui2.AbsolutePosition.Y + gui2.AbsoluteSize.Y)) or ((gui2.AbsolutePosition.X < gui1.AbsolutePosition.X + gui1.AbsoluteSize.X and gui2.AbsolutePosition.X + gui2.AbsoluteSize.X > gui1.AbsolutePosition.X) and (gui2.AbsolutePosition.Y > gui1.AbsolutePosition.Y and gui2.AbsolutePosition.Y < gui1.AbsolutePosition.Y + gui1.AbsoluteSize.y))

			if C then
				table.inset(Colliding, v)
			end
		end

		return Colliding
	end

	local CF = framework:GetCFrame(Object)
	local Size
	if Object:IsA("Model") then
		Size = Object:GetModelSize()
	else
		Size = Object.Size
	end

	local Part = Instance.new("Part", workspace)
	Part.Anchored = true
	Part.CanCollide = true
	Part.Transparency = 1
	--Part.FormFactor = "Custom"
	Part.Size = Size
	Part.CFrame = CF

	local Colliding, RealColliding = Part:GetTouchingParts(), {}
	Part:Destroy()

	for _,v in pairs(Colliding) do
		if not framework:ValueExistsInTable(IgnoreList, v) then
			table.insert(RealColliding, v)
		end
	end

	return RealColliding
end

function framework:IsColliding(Object, SecondObject, IgnoreList)
	CheckArg("IsColliding", 1, Object, "instance:Model/instance:BasePart/instance:GuiObject")
	CheckArg("IsColliding", 2, SecondObject, "instance:Model/instance:BasePart/instance:GuiObject")

	local Colliding = framework:GetColliding(Object, IgnoreList)

	for _,v in pairs(Colliding) do
		if v == SecondObject or (not v:IsA("GuiObject") and v:IsDescendantOf(SecondObject)) then
			return true
		end
	end

	return false
end


-- Player API
local PlayerStats = {} -- wait.... wat?


function framework:PlayerFromUserID(UserID)
	CheckArg("PlayerFromUserID", 1, UserID, "number")

	return game.Players:GetPlayerByUserId(UserID)
end

function framework:UsernameFromUserID(UserID)
	CheckArg("UsernameFromUserID", 1, UserID, "number")
	
	if not Cache.UNC then
		Cache.UNC = {}
	end
	if Cache.UNC[tostring(UserID)] and CacheEnabled then
		return Cache.UNC[tostring(UserID)][1]
	end

	local N = "[Null]"
	if UserID < 0 then
		-- guest IDs
		local GuestID = tostring(UserID):sub(-4):gsub("^0*","") -- ty einsteinK

		N = "Guest " .. (GuestID == "" and "0" or GuestID)
	else
		N = game.Players:GetNameFromUserIdAsync(UserID)
	end
	
	Cache.UNC[tostring(UserID)] = {N, tick()}
	return N
end

function framework:UserIDFromUsername(Username)
	CheckArg("UserIDFromUsername", 1, Username, "string")

	if not Cache.UIDC then
		Cache.UIDC = {}
	end
	if Cache.UIDC[Username] and CacheEnabled then
		return Cache.UIDC[Username][1]
	end


	local UserID = game.Players:GetUserIdFromNameAsync(Username)

	Cache.UIDC[Username] = {UserID, tick()}
	return UserID
end


framework.PlayerAdded = NewSignal()

if framework:IsLocal() then
	game.Players.ChildAdded:connect(function(...)
		framework.PlayerAdded:fire(...)
	end)
else
	game.Players.PlayerAdded:connect(function(...)
		framework.PlayerAdded:fire(...)
	end)
end


framework.PlayerRemoving = NewSignal()

if framework:IsLocal() then
	game.Players.ChildRemoved:connect(function(...)
		framework.PlayerRemoving:fire(...)
	end)
else
	game.Players.PlayerRemoving:connect(function(...)
		framework.PlayerRemoving:fire(...)
	end)
end


framework.PlayerRemoved = NewSignal()

game.Players.ChildRemoved:connect(function(...)
	framework.PlayerRemoved:fire(...)
end)


function framework.SafePlayerAdded(Callback)
	CheckArg("framework.SafePlayerAdded", 1, Callback, "function")

	local Players = game.Players:GetPlayers()
	local con = game.Players.PlayerAdded:connect(function(...)
		Callback(...)
	end)
	
	for _,v in pairs(Players) do
		Callback(v)
	end
	
	return function()
		con:disconnect()
	end
end

function framework:GetSessionHistory(Player)
	CheckArg("GetSessionHistory", 1, Player, "instance:Player")

	warn("framework::GetSessionHistory  was removed in v2!")
	
	return {}
end


-- Ban API
local bannedDataStore
if not framework:IsLocal() then
	pcall(function()
		bannedDataStore = game:GetService("DataStoreService"):GetDataStore("XeptixFramework_BanDatabase")
	end)
	if not bannedDataStore then
		bannedDataStore = _G.XeptixFramework_PesudoDS()
	end

	framework:AddEvent("XeptixFramework/BanRemote", function(Player, Action, ...)
		if not Settings.ClientCanUseBanAPI then -- check on server too
			return error(tostring(Player) .. " attempted to use Ban API from client while it is disabled! Possibly an exploit!")
		end

		if Action == "Kick" then
			framework:Kick(...)
		elseif Action == "Ban" then
			framework:Ban(...)
		elseif Action == "Unban" then
			framework:Unban(...)
		end
	end)
else
	framework:AddFunction("XeptixFramework/BanRemote", function(Action, x)
		if Action == "Reason" then
			pcall(function()
				game:SetMessage(x)
			end)

			local Message = Instance.new("Message", game.Players.LocalPlayer.PlayerGui)
			Message.Text = x
		end
	end)
end

function framework:Kick(Player, Reason)
	CheckArg("Kick", 1, Player, "instance:Player")

	if framework:IsLocal() then
		if not Settings.ClientCanUseBanAPI then
			return error("The Ban API is currently disabled on clients! To allow the Ban API to be used locally, please check the \"ClientCanUseBanAPI\" setting!")
		end

		return framework:FireServer("XeptixFramework/BanRemote", "Kick", Player, Reason)
	end

	local Save = framework:WaitForData(Player)

	Save:Update("XeptixFramework/BanHistory", function(Old)
		local New = framework:DecodeJSON(Old or '[]')

		table.insert(New, {
			Type = 3,
			Timestamp = tick(),
			Reason = Reason or "",
			Duration = Duration or 0
		})

		return framework:EncodeJSON(New)
	end)

	Player:Kick("You were kicked from the server" .. (Reason and ":\n" .. Reason or "!"))
end

function framework:Ban(Player, Reason, Duration)
	CheckArg("Ban", 1, Player, "number/instance:Player")
	if Reason then
		CheckArg("Ban", 2, Reason, "string")
	elseif Duration then
		CheckArg("Ban", 3, Duration, "number")
	end

	if framework:IsLocal() then
		if not Settings.ClientCanUseBanAPI then
			return error("The Ban API is currently disabled on clients! To allow the Ban API to be used locally, please check the \"ClientCanUseBanAPI\" setting!")
		end

		return framework:FireServer("XeptixFramework/BanRemote", "Ban", Player, Reason, Duration)
	end

	if not Duration then
		Duration = 9999999
	end
	
	
	local BanData = {
		Type = 2,
		Timestamp = tick(),
		Reason = Reason or "",
		Duration = Duration or 0
	}

	local id = type(Player) == "number" and Player or Player.userId
	bannedDataStore:UpdateAsync("List", function(Banned)
		if type(Banned) ~= "table" then Banned = {} end
		
		Banned[tostring(id)] = tick() + (Duration * 3600)

		local New = framework:EncodeJSON(Banned)
		BannedList.Value = New
				
		return Banned
	end)
	
	
	local Save = framework:LoadData(Player)
	Save:Set("XeptixFramework/Banned", framework:EncodeJSON(BanData))

	Save:Update("XeptixFramework/BanHistory", function(Old)
		local New = framework:DecodeJSON(Old or '[]')

		table.insert(New, BanData)

		return framework:EncodeJSON(New)
	end)

	local Player = framework:PlayerFromUserID(id)
	if Player then
		Player:Kick("You were banned from the game for " .. framework:TimeToString((Duration or 0) * 3600) .. (Reason and ":\n" .. Reason or "!"))
	end
end

function framework:Unban(UserID)
	CheckArg("Unban", 1, UserID, "number")

	if framework:IsLocal() then
		if not Settings.ClientCanUseBanAPI then
			return error("The Ban API is currently disabled on clients! To allow the Ban API to be used locally, please check the \"ClientCanUseBanAPI\" setting!")
		end

		return framework:FireServer("XeptixFramework/BanRemote", "Unban", UserID)
	end

	local id = type(UserID) == "number" and UserID or UserID.userId
	bannedDataStore:UpdateAsync("List", function(Banned)
		if type(Banned) ~= "table" then Banned = {} end
		
		local NewBanned = {}

		for _,v in pairs(Banned) do
			if tonumber(_) ~= id then
				NewBanned[_] = v
			end
		end

		local New = framework:EncodeJSON(NewBanned)
		BannedList.Value = New
				
		return NewBanned
	end)

	local Save = framework:LoadData(UserID)

	if not Save then
		error("Unable to unban user; no save exists for UserID("..UserID..")")
	end

	Save:Set("XeptixFramework/Banned", false)
end

function framework:GetBanHistory(Player)
	CheckArg("GetBanHistory", 1, Player, "instance:Player")

	local Save = framework:WaitForData(Player)

	return framework:DecodeJSON(Save:Get("XeptixFramework/BanHistory"))
end


-- Leaderboard API
local LeaderboardCache = {}
local LeaderboardPreciseCache = {}
local LeaderboardDebounce = {}
local PlayerPositionCache = {}
local UpdateTaskCreated = {}
local CanUpdateTask = {}

framework.LeaderboardUpdated = NewSignal()


function framework:GetLeaderboard(Key, SortType, Start, Limit)
	CheckArg("GetLeaderboard", 1, Key, "string")
	CheckArg("GetLeaderboard", 2, SortType, "number")
	CheckArg("GetLeaderboard", 3, Start, "number")
	CheckArg("GetLeaderboard", 4, Limit, "number")

	if framework:IsLocal() then
		return framework:InvokeServer("XeptixFramework/LeaderboardRemote", "Get", Key, SortType, Start, Limit)
	end
	
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if LeaderboardDebounce[Key] then
		repeat
			wait()
		until not LeaderboardDebounce[Key]
	end
	
	if Limit > 250 then Limit = 250 end
	
	local K = Key .. "-" .. SortType .. "-" .. Start .. "-" .. Limit
	if LeaderboardPreciseCache[K] then
		return LeaderboardPreciseCache[K]
	elseif LeaderboardCache[Key] then
		-- the leaderboard is already up-to-date,
		local Leaderboard = {}
		local T = "GTL"
		if SortType == 2 then T = "LTG" end
		
		local Start, Finish, Pos = Start, Start + Limit, 0
		for i = Start, Finish, 1 do
			if i > 0 then
				local Entry = LeaderboardCache[Key][T][i]
				if Entry then
					Pos = Pos + 1
					Entry.Name = Entry.N
					Entry.UserID = Entry.I
					Entry.Value = Entry.V
					Entry.Username = Entry.Name
					
					if Entry.E then
						Entry.Exec = true -- intense defense only
					end
					
					if Entry.Value and tonumber(Entry.Value) then
						Entry.Value = tonumber(Entry.Value)
					end
					
					if Entry.UserID and tonumber(Entry.UserID) then
						Entry.UserID = tonumber(Entry.UserID)
					end
					
					if Entry.Position and tonumber(Entry.Position) then
						Entry.Position = tonumber(Entry.Position)
					elseif not Entry.Position then
						Entry.Position = Pos
					end
					
					table.insert(Leaderboard, Entry)
				end
			end
		end
		
		LeaderboardPreciseCache[K] = Leaderboard
		return Leaderboard
	end
	
	-- update the leaderboard
	framework:UpdateLeaderboard(Key)
	return framework:GetLeaderboard(Key, SortType, Start, Limit)
end


function framework:UpdateLeaderboard(Key)
	CheckArg("UpdateLeaderboard", 1, Key, "string")

	if framework:IsLocal() then
		return framework:InvokeServer("XeptixFramework/LeaderboardRemote", "Update", Key)
	end
	
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if CanUpdateTask[Key] and CanUpdateTask[Key] > tick() then
		return output("You can not update the leaderboard for another " .. math.floor(CanUpdateTask[Key] - tick()) .. " seconds!", 1)
	end
	
	if LeaderboardsDisabled or LeaderboardDebounce[Key] then return end

	LeaderboardDebounce[Key] = true

	-- update it	
	local Leaderboard = DCRequest("leaderboard/get", "post", {Key = Key, Tick = tick()})
	if Leaderboard == "disabled" then LeaderboardsDisabled = true return end
	local Success, JSON = pcall(function()
		return HttpService:JSONDecode(Leaderboard)
	end)
	
	if not Success or type(JSON) ~= "table" then
		wait(30)
		LeaderboardDebounce[Key] = false
		return framework:UpdateLeaderboard(Key)--output("An unexpected error occured while updating the leaderboard \"" .. Key .. "\"!", 3)
	end
	
	local UpdateDelay = 300
	if type(JSON.NU) == "number" and JSON.NU <= 420 then
		local x = JSON.NU
		UpdateDelay = math.floor(x)
		print("DevCircle told Xeptix Framework to update the '"..Key.."' leaderboard in "..UpdateDelay.." seconds!")
	end
	
	
	if UpdateDelay < 60 then
		UpdateDelay = 60
	end
	CanUpdateTask[Key] = tick() + UpdateDelay
	LeaderboardCache[Key] = JSON
	
	-- set all of the values and what-not
	LeaderboardPreciseCache = {}
	PlayerPositionCache = {}
	
	if not UpdateTaskCreated[Key] then
		UpdateTaskCreated[Key] = true
		
		delay(UpdateDelay, function()
			UpdateTaskCreated[Key] = false
			CanUpdateTask[Key] = false
			framework:UpdateLeaderboard(Key)
		end)
	end
	
	LeaderboardDebounce[Key] = false
	framework.LeaderboardUpdated:fire(Key)
	framework:FireAllClients("XeptixFramework/LeaderboardRemote", Key)
end

function framework:GetLeaderboardPositionForPlayer(Key, Player)
	CheckArg("GetLeaderboardPositionForPlayer", 1, Key, "string")
	CheckArg("GetLeaderboardPositionForPlayer", 2, Player, "number/instance:Player")

	if framework:IsLocal() then
		return unpack(framework:InvokeServer("XeptixFramework/LeaderboardRemote", "Position", Key, Player))
	end
	
	if not Connected then
		output("To use this feature, you must connect this game to DevCircle! To do so, while in studio, click the \"Connect\" button in the Xeptix Framework Plugin!", 2)
	end

	
	local ID = type(Player) == "number" and Player or Player.userId

	if PlayerPositionCache[Key] and PlayerPositionCache[Key][tostring(ID)] then
		return PlayerPositionCache[Key][tostring(ID)]
	elseif not PlayerPositionCache[Key] then
		PlayerPositionCache[Key] = {}
	end


	local Leaderboard = framework:GetLeaderboard(Key, 1, 0, 999999999) -- out of the 1st 1 billion... good enough rite?
	local Pos = 0

	for _,v in pairs(Leaderboard) do
		if math.random(420000) == 1 then wait() end -- for super large leaderboards

		Pos = Pos + 1
		if v.UserID == ID then
			PlayerPositionCache[Key][tostring(ID)] = Pos

			return Pos, v.Value
		end
	end

	return Pos + 1, 0 -- not on the leaderboard
end


if not framework:IsLocal() then
	-- allow the client to use the leaderboard
	framework:AddFunction("XeptixFramework/LeaderboardRemote", function(Player, Action, ...)
		if Action == "Get" then
			return framework:GetLeaderboard(...)
		elseif Action == "Update" then
			return framework:UpdateLeaderboard(...)
		elseif Action == "Position" then
			return {framework:GetLeaderboardPositionForPlayer(...)}
		end
	end)
else
	framework:AddEvent("XeptixFramework/LeaderboardRemote", function(Key)
		framework.LeaderboardUpdated:fire(Key)
	end)
end


-- Player Data API
if not framework:IsLocal() and not Stuff:findFirstChild("[ReplicatedDataContainer]") then
	-- We need to install the Replicated Data Container for clients to read (not write) the save profile
	Instance.new("Folder", Stuff).Name = "[ReplicatedDataContainer]"
end

local ReplicateDataContainer = Stuff:WaitForChild("[ReplicatedDataContainer]")
framework._ReplicateDataContainer = ReplicateDataContainer

if not framework:IsLocal() then
	ReplicateDataContainer:ClearAllChildren()
end

local XDS = require(Libs.XeptixDataStorage)

if not framework:IsLocal() then
	local DataAPI = {}
	
	DataAPI.SaveCaches = {}
	
	
	framework.KeyChanged = NewSignal()


	function framework:addKeyToReplicateData(RDC, key, value)
		local i, val, json = "Model"
		local t = framework:Type(value)

		if t == "number" then
			i, val = "NumberValue", value
		elseif t == "string" then
			i, val = "StringValue", value
		elseif t == "boolean" then
			i, val = "BoolValue", value
		elseif t == "color3" then
			i, val = "Color3Value", value
		elseif t == "brickcolor" then
			i, val = "BrickColorValue", value
		elseif t == "vector3" then
			i, val = "Vector3Value", value
		elseif t == "cframe" then
			i, val = "CFrameValue", value
		elseif t == "table" then
			i, val, json = "StringValue", framework:EncodeJSON(value), true
		end

		if RDC:findFirstChild(key) then
			RDC:findFirstChild(key):Destroy()
		end
		
		local x = Instance.new(i)
		x.Name = key
		
		if json then
			Instance.new("Model", x).Name = "<json>"
			x.Archivable = false
		end
		
		if val then
			x.Value = val
		end
		
		x.Parent = RDC
	end
	
	
	local LoadingDB = {}
	function framework:LoadData(Player) -- Player can be a player instance or a userid
		CheckArg("LoadData", 1, Player, "instance:Player/number")

		local id = Player
		if type(id) ~= "number" then
			id = Player.userId
		end
		
		if LoadingDB[tostring(id)] then
			return framework:WaitForData(id)
		end

		LoadingDB[tostring(id)] = true
		local Save = XDS:Load(id)
		
		if not Save then
			return output("An error occurred while loading data for:",tostring(Player), 3)
		end
		
		if not ReplicateDataContainer:findFirstChild(tostring(id)) then
			local RDC = Instance.new("Folder")
			RDC.Name = tostring(id)
			
			for _,v in pairs(Save.dataSet) do
				framework:addKeyToReplicateData(RDC, _, v)
			end
			
			if ReplicateDataContainer:findFirstChild(tostring(id)) then
				ReplicateDataContainer:findFirstChild(tostring(id)):Destroy()
			end
			
			RDC.Parent = ReplicateDataContainer
		end
		
		LoadingDB[tostring(id)] = false
		return Save
	end
	
	function framework:UnloadData(Player) -- Player can be a player instance or a userid
		CheckArg("UnloadData", 1, Player, "instance:Player/number")

		local id = Player
		if type(Player) == "userdata" and Player:IsA("Player") then
			id = Player.userId
		end
		
		if ReplicateDataContainer:findFirstChild(tostring(id)) then
			ReplicateDataContainer:findFirstChild(tostring(id)):Destroy()
		end
	end
	
	function framework:WaitForData(Player)
		CheckArg("WaitForData", 1, Player, "instance:Player/number")

		wait() -- wait a sec then try to load the data, this is kinda haxy but helps with performance and prevents overwriting of data so in the long run it's our best route. We can't rely on Double-Caching anymore, it's unreliable, too performance costly, and has caused too much data loss. This system should be 99.999% reliable ;)
		
		return framework:LoadData(Player)
	end
	
	function framework:GetData(Player)
		CheckArg("GetData", 1, Player, "instance:Player/number")

		local id = Player
		if type(Player) == "userdata" and Player:IsA("Player") then
			id = Player.userId
		end
		
		return framework:LoadData(Player)
	end
	
	
	framework.SafePlayerAdded(function(Player)
		-- load their data
		--output("Preparing data for "..Player.Name)
		
		local st = tick()
		local Data = framework:LoadData(Player) -- load their data when they enter by default so its ready whenever they need it
		
		output("Successfully loaded data for "..Player.Name.."!\n\telapsed time: " .. tostring(tick() - st):sub(0,6) .. "s")

		-- ban stuff
		if Data:Get('XeptixFramework/Banned') then
			-- check if their banned
			local BanData = framework:DecodeJSON(Data:Get('XeptixFramework/Banned'))

			if BanData.Timestamp + (BanData.Duration * 3600) > tick() then
				-- Player is banned, let's get rid of them
				Player:Kick("You are banned from the game for " .. framework:TimeToString((BanData.Timestamp + (BanData.Duration * 3600)) - tick()) .. (BanData.Reason and ":\n" .. BanData.Reason or "!"))
				
				return output("Banned player attempted to join and was removed:",tostring(Player))
			end
		end

		if not Data:Get("XeptixFramework/BanHistory") then
			Data:Set("XeptixFramework/BanHistory", "[]")
		end

		-- product history stuffs
		if not Data:Get("XeptixFramework/ProductHistory") then
			Data:Set("XeptixFramework/ProductHistory", "[]")
		end

		-- visit log
		if Data:Get("XeptixFramework/SessionHistory") then
			Data:Set("XeptixFramework/SessionHistory", nil)
		end

		Data:Set("XeptixFramework/CurrentSessionTimestamp", tick())
		
		Data:Set("XeptixFramework/Username", Player.Name)
		Data:Set("XeptixFramework/UserID", Player.userId)
		
		-- all loading operations are finished, signal that the data is ready
		local signal = Instance.new("ObjectValue", Player)
		signal.Name = "[DataReady]"

		-- open up the data for use by the game
		DataAPI.SaveCaches[tostring(Player.userId)] = Data
	end)
	
	framework.PlayerDataStoreAPI = DataAPI -- the internal API for PlayerDataStore - don't document
else
	LocalSaveCache = {}
	
	framework.KeyChanged = NewSignal()
	
	local function NewDataProfile(Data)
		if LocalSaveCache[Data.Name] then return LocalSaveCache[Data.Name] end
		
		LocalSaveCache[Data.Name] = {dataSet = {}, userId = tonumber(Data.Name), lastSaved = 0}
		
		LocalSaveCache[Data.Name].GetKeys = function(Self)
			if not LocalSaveCache[Data.Name] then return end
			local keys = {}

			for _,v in pairs(LocalSaveCache[Data.Name].dataSet) do
				-- filter out internal ones, just like on the server
				if _:sub(0,16) == "XeptixFramework/" or _:sub(0,22) == "XF_KeyChangeTimestamps" then
					-- do nothing for now
				else
					table.insert(keys, _)
				end
			end

			return keys
		end

		LocalSaveCache[Data.Name].Get = function(Self, Key)
			if not LocalSaveCache[Data.Name] then return end
			
			if type(Self) == "string" then
				return LocalSaveCache[Data.Name].dataSet[Self]
			end
			
			return LocalSaveCache[Data.Name].dataSet[Key]
		end
		
		LocalSaveCache[Data.Name].Set = function(Self, Key, Value)
			return output("The client is unable to set data for security reasons!", 2)
		end
		
		
		local function NewValue(Value)
			if Value:IsA("Model") or not Value.Parent or not Data.Parent then return end
			
			local json = Value:findFirstChild("<json>")
			if Value:IsA("StringValue") and (json or not Value.Archivable) then
				LocalSaveCache[Data.Name].dataSet[Value.Name] = framework:DecodeJSON(Value.Value)
			else
				LocalSaveCache[Data.Name].dataSet[Value.Name] = Value.Value
			end

			if Value.Name == "XeptixFramework/LastSaved" then
				LocalSaveCache[Data.Name].lastSaved = Value.Value
			end
			
			local function ValChanged(Prop)
				if not LocalSaveCache[Data.Name] then return end
				
				local OldValue = LocalSaveCache[Data.Name].dataSet[Value.Name]
				if Value:IsA("StringValue") and (Value:findFirstChild("<json>") or not Value.Archivable) then
					LocalSaveCache[Data.Name].dataSet[Value.Name] = framework:DecodeJSON(Value.Value)
				else
					LocalSaveCache[Data.Name].dataSet[Value.Name] = Value.Value
				end
				
				if Value.Name == "XeptixFramework/LastSaved" then
					LocalSaveCache[Data.Name].lastSaved = Value.Value
				end
				
				local Plr = framework:PlayerFromUserID(tonumber(Data.Name))
				if not Plr then
					return --output("No player found, StatChanged event couldn't fire! UserID: " .. Data.Name .. ", ID2Player: " .. tostring(framework:PlayerFromUserID(tonumber(Data.Name))), 3)
				end
				
				framework.KeyChanged:fire(Plr, Value.Name, OldValue, Value.Value)
			end
			Value.Changed:connect(ValChanged)
			if json then json.Changed:connect(ValChanged) end
		end
		
		Data.ChildAdded:connect(NewValue)
		for _,v in pairs(Data:GetChildren()) do
			NewValue(v)
		end
		
		Data.Changed:connect(function(Prop)
			if Prop == "Parent" and not ReplicateDataContainer:findFirstChild(Data.Name) then
				LocalSaveCache[Data.Name] = nil
			end
		end)
	end
	
	ReplicateDataContainer.ChildAdded:connect(NewDataProfile)
	for _,v in pairs(ReplicateDataContainer:GetChildren())do
		NewDataProfile(v)
	end

	function framework:LoadData(Player)
		output("framework::LoadData is currently disabled on all clients for security purposes!", 2)
	end
	
	function framework:UnloadData(Player)
		CheckArg("UnloadData", 1, Player, "instance:Player/number")

		local id = Player
		if type(Player) == "userdata" and Player:IsA("Player") then
			id = Player.userId
		end
		
		local Data = LocalSaveCache[tostring(id)]
		
		if not Data then
			return output("Unable to unload data; no data exists!", 3)
		end
		
		-- any operations before unload go here	
		
		LocalSaveCache[tostring(id)] = nil
	end
	
	function framework:WaitForData(Player)
		CheckArg("WaitForData", 1, Player, "instance:Player/number")

		local id = Player
		if type(Player) == "userdata" and Player:IsA("Player") then
			id = Player.userId
		end
		
		if LocalSaveCache[tostring(id)] then
			return LocalSaveCache[tostring(id)]
		end
		
		repeat
			local x = ReplicateDataContainer:findFirstChild(tostring(id))
			if x then
				NewDataProfile(x)
			end
			
			wait()
		until LocalSaveCache[tostring(id)]
		
		return LocalSaveCache[tostring(id)]
	end
	
	function framework:GetData(Player)
		CheckArg("GetData", 1, Player, "instance:Player/number")

		local id = Player
		if type(Player) == "userdata" and Player:IsA("Player") then
			id = Player.userId
		end
		
		if not LocalSaveCache[tostring(id)] then
			local x = ReplicateDataContainer:findFirstChild(tostring(id))
			if x then
				NewDataProfile(x)
			end
		end
		
		local Data = LocalSaveCache[tostring(id)]
				
		return Data
	end
	
	framework.PlayerRemoved:connect(function(Player)
		framework:UnloadData(Player)
	end)
end


-- Badge API
local BadgeService = game:GetService("BadgeService")

framework.BadgeAwarded = NewSignal()

function framework:AwardBadge(UserID, BadgeID)
	CheckArg("AwardBadge", 1, UserID, "number")
	CheckArg("AwardBadge", 2, BadgeID, "number")
	
	if framework:IsLocal() then
		return output("framework::AwardBadge is only available on the server!", 3)
	end

	local Player = framework:PlayerFromUserID(UserID)
	if not Player then
		return output("Unable to award badge, player is not in-game!", 3)
	end
	
	if framework:HasBadge(UserID, BadgeID) then
		-- they already own the badge, is there anything to even do?
	else
		BadgeService:AwardBadge(UserID, BadgeID)
		
		Cache.HasBadge[tostring(UserID) .."/".. tostring(BadgeID)] = nil -- clear the cache ;)
		framework.BadgeAwarded:fire(Player, BadgeID)
	end
end

function framework:HasBadge(UserID, BadgeID)
	CheckArg("HasBadge", 1, UserID, "number")
	CheckArg("HasBadge", 2, BadgeID, "number")
	
	if not Cache.HasBadge then
		Cache.HasBadge = {}
	end
	
	if Cache.HasBadge[tostring(UserID) .."/".. tostring(BadgeID)] and CacheEnabled then
		return Cache.HasBadge[tostring(UserID) .."/".. tostring(BadgeID)][1]
	end

	if framework:IsLocal() then
		return framework:InvokeServer("XeptixFramework/HasBadge", UserID, BadgeID)
	end

	return game.BadgeService:UserHasBadge(UserID, BadgeID)
end

if not framework:IsLocal() then
	framework:AddFunction("XeptixFramework/HasBadge", function(Player, UserID, BadgeID)
		return framework:HasBadge(UserID, BadgeID)
	end)
end


-- DevProduct API
function framework:GetProductInfo(a, b) -- currently not documented
	local k = tostring(a).."/"..tostring(b)
	
	if not Cache.GPI then
		Cache.GPI = {}
	end
	if Cache.GPI[k] and CacheEnabled then
		return Cache.GPI[k][1]
	end
	
	local x = {game.MarketplaceService:GetProductInfo(a, b), tick()}
	if Cache.GPI and CacheEnabled then
		Cache.GPI[k] = x
	end
	
	return x[1]
end

if Settings.DeveloperProductAPIEnabled then
	if not framework:IsLocal() then
		local PurchaseHistory
		pcall(function()
			PurchaseHistory = game:GetService("DataStoreService"):GetDataStore("XeptixFramework_ProductPurchaseHistory")
		end)
		if not PurchaseHistory then
			PurchaseHistory = _G.XeptixFramework_PesudoDS()
		end
		local LocalPH = {}
		
		game:GetService"MarketplaceService".ProcessReceipt = function(Receipt)
			-- check if it's already been processed
			local playerProductKey = Receipt.PlayerId .. ":" .. Receipt.PurchaseId
			if LocalPH[playerProductKey] or PurchaseHistory:GetAsync(playerProductKey) then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end

			-- get receipt info
			local ProductID = Receipt.ProductId
			local Currency = Receipt.CurrencyType == Enum.CurrencyType.Tix and "Tix" or "Robux"
			local CurrencySpent = Receipt.CurrencySpent
			local Save = framework:LoadData(Receipt.PlayerId)

			if Save then
				local Passed

				if script['Developer Products']:findFirstChild(ProductID) then
					Passed = require(script['Developer Products']:findFirstChild(ProductID))(Receipt, Receipt.CurrencyType, CurrencySpent, Receipt.PlayerId, Save)
				end
	
				if not Passed or Passed == Enum.ProductPurchaseDecision.NotProcessedYet then
					return Enum.ProductPurchaseDecision.NotProcessedYet
				end
				
				
				PurchaseHistory:SetAsync(playerProductKey, true)
				LocalPH[playerProductKey] = true
				ServerData.Sales = ServerData.Sales + 1
				ServerData[Currency .. 'Earned'] = (ServerData[Currency .. 'Earned'] or 0) + CurrencySpent
				
				Save:Update('XeptixFramework/PurchaseHistory', function(Old)
					local New = framework:DecodeJSON(Old or '[]') or {}

					table.insert(New, {
						ProductID = ProductID,
						CurrencyType = Currency,
						CurrencySpent = CurrencySpent,
						Receipt = Receipt,
						Timestamp = tick()
					})

					return framework:EncodeJSON(New)
				end)
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end


			-- Signal ROBLOX that the transaction was completed successfully
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
end

function framework:PromptProductPurchase(Player, ProductId)
	CheckArg("PromptProductPurchase", 1, Player, "instance:Player")
	CheckArg("PromptProductPurchase", 2, ProductId, "number")

	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/PromptProductPurchase", Player, ProductId)
	end

	--Currency = Currency == "robux" and 1 or Currency == "tix" and 2 or 0

	MarketplaceService:PromptProductPurchase(Player, ProductId)
end

function framework:GetPurchaseHistory(Player)
	CheckArg("GetPurchaseHistory", 1, Player, "instance:Player")

	local Save = framework:WaitForData(Player)
	
	return framework:DecodeJSON(Save:Get("XeptixFramework/ProductHistory"))
end


-- Time API
local GetDateLib = require(Libs.GetDate)

function framework:TimestampToDate(Timestamp, Format)
	CheckArg("TimestampToDate", 1, Timestamp, "nil/number")
	CheckArg("TimestampToDate", 2, Format, "nil/string")
	
	return GetDateLib(Timestamp or tick()):format(Format or "#M/#d/#Y #H:#m #a")
end

function framework:TimeToString(Time, Limit, ShortLimit)
	CheckArg("TimeToString", 1, Time, "number")
	CheckArg("TimeToString", 2, Limit, "nil/number")
	CheckArg("TimeToString", 3, ShortLimit, "nil/number")
	
	if not Cache.TTS then Cache.TTS = {} end
	local oK = tostring(math.floor(Time)) .."/".. tostring(Limit) .."/" .. tostring(ShortLimit)
	if Cache.TTS[oK] and Cache.TTS[oK][1] and CacheEnabled then return Cache.TTS[oK][1] end

	Time = math.floor(Time)

	if math.floor(Time) <= 0 then
		if ShortLimit or 3 <= 0 then
			return "0s"
		end
		
		return "0 seconds"
	end
	
	if not Limit then
		Limit = 7
	end
	
	if not ShortLimit then
		ShortLimit = 3 -- start abbreviating after the time starts getting into days
	end
	
	
	local Minutes, Hours, Days, Weeks, Months, Years, Decades = 60, 3600, 86400, 604800, 2635200, 31557600, 315576000
	local TimeStr, TimeUnit, ShortTime, Override = '','second', 99
	
	local function Spc()
		if TimeStr == "" then
			return ""
		end
		
		return " "
	end
	
	
	if (Override or Time / Decades >= 1) and Limit >= 7 then
		local Num = math.floor(Time / Decades)
		Time, TimeUnit, Override = Time - (Decades * Num), 'decade', true    -- 7
		
		if ShortLimit <= 7 and ShortTime == 99 then
			ShortTime = 1
		end
		
		TimeStr = TimeStr .. Spc() .. Num .. (ShortTime > 1 and " " or "") .. TimeUnit:sub(0,ShortTime)
		if math.floor(Time) ~= 1 and ShortTime > 1 then
			TimeStr = TimeStr .. 's'
		end
	end
	if (Override or Time / Years >= 1) and Limit >= 6 then
		local Num = math.floor(Time / Years)
		Time, TimeUnit, Override = Time - (Years * Num), 'year', true    -- 6
		
		if ShortLimit <= 6 then
			ShortTime = 1
		end
		
		TimeStr = TimeStr .. Spc() .. Num .. (ShortTime > 1 and " " or "") .. TimeUnit:sub(0,ShortTime)
		if math.floor(Time) ~= 1 and ShortTime > 1 then
			TimeStr = TimeStr .. 's'
		end
	end
	if (Override or Time / Months >= 1) and Limit >= 5 then
		local Num = math.floor(Time / Months)
		Time, TimeUnit, Override = Time - (Months * Num), 'month', true    -- 5
		
		if ShortLimit <= 5 then
			ShortTime = 1
		end
		
		TimeStr = TimeStr .. Spc() .. Num .. (ShortTime > 1 and " " or "") .. TimeUnit:sub(0,ShortTime)
		if math.floor(Time) ~= 1 and ShortTime > 1 then
			TimeStr = TimeStr .. 's'
		end
	end
	if (Override or Time / Weeks >= 1 and Limit >= 4) and Limit >= 4 then
		local Num = math.floor(Time / Weeks)
		Time, TimeUnit, Override = Time - (Weeks * Num), 'week', true    -- 4
		
		if ShortLimit <= 4 then
			ShortTime = 1
		end
		
		TimeStr = TimeStr .. Spc() .. Num .. (ShortTime > 1 and " " or "") .. TimeUnit:sub(0,ShortTime)
		if math.floor(Time) ~= 1 and ShortTime > 1 then
			TimeStr = TimeStr .. 's'
		end
	end
	if (Override or Time / Days >= 1) and Limit >= 3 then
		local Num = math.floor(Time / Days)
		Time, TimeUnit, Override = Time - (Days * Num), 'day', true    -- 3
		
		if ShortLimit <= 3 then
			ShortTime = 1
		end
		
		TimeStr = TimeStr .. Spc() .. Num .. (ShortTime > 1 and " " or "") .. TimeUnit:sub(0,ShortTime)
		if math.floor(Time) ~= 1 and ShortTime > 1 then
			TimeStr = TimeStr .. 's'
		end
	end
	if (Override or Time / Hours >= 1) and Limit >= 2 then
		local Num = math.floor(Time / Hours)
		Time, TimeUnit, Override = Time - (Hours * Num), 'hour', true    -- 2
		
		if ShortLimit <= 2 then
			ShortTime = 1
		end
		
		TimeStr = TimeStr .. Spc() .. Num .. (ShortTime > 1 and " " or "") .. TimeUnit:sub(0,ShortTime)
		if math.floor(Time) ~= 1 and ShortTime > 1 then
			TimeStr = TimeStr .. 's'
		end
	end
	if (Override or Time / Minutes >= 1) and Limit >= 1 then
		local Num = math.floor(Time / Minutes)
		Time, TimeUnit, Override = Time - (Minutes * Num), 'minute', true    -- 1
		
		if ShortLimit <= 1 then
			ShortTime = 1
		end
		
		TimeStr = TimeStr .. Spc() .. Num .. (ShortTime > 1 and " " or "") .. TimeUnit:sub(0,ShortTime)
		if math.floor(Time) ~= 1 and ShortTime > 1 then
			TimeStr = TimeStr .. 's'
		end
	end
	
	TimeStr = TimeStr .. Spc() .. math.floor(Time) .. (ShortTime > 1 and " " or "") .. ('second'):sub(0,ShortTime)
	if math.floor(Time) ~= 1 and ShortTime > 1 then
		TimeStr = TimeStr .. 's'
	end
	
	Cache.TTS[oK] = TimeStr
	
	return TimeStr
end

function framework:TimestampToString(Timestamp, ...)
	CheckArg("TimestampToString", 1, Timestamp, "number")

	local Time = Timestamp
	if Timestamp >= tick() then
		Time = Timestamp - tick()
	else
		Time = tick() - Timestamp
	end
	
	return framework:TimeToString(Time, ...)
end

function framework:GetDate(Timestamp)
	CheckArg("GetDate", 1, Timestamp, "nil/number")
	
	return GetDateLib(Timestamp or tick())
end


-- Pathfinding API
-- todo: make this!!!


-- Remote API
framework.events = {}
framework.functions = {}
_G.framework = framework -- fixed v1 events/functions :P

function framework:AddEvent(Mod, F)
	CheckArg("AddEvent", 1, Mod, "instance:ModuleScript/string")

	local ModN = tostring(Mod)
	local ModF
	if type(Mod) == "string" and type(F) == "function" then
		ModF = F
	else
		ModF = require(Mod)
	end
	
	local RunF
	if framework:IsLocal() then
		RunF = function(...)
			return ModF(...)
		end
	else
		RunF = function(Player, ...)
			return ModF(Player, ...)
		end
	end
	
	if framework.events[ModN] then
		return output("Unable to add event \""..ModN.."\", already exists!", 3)
	else
		framework.events[ModN] = RunF
	end
end

function framework:AddFunction(Mod, F)
	CheckArg("AddFunction", 1, Mod, "instance:ModuleScript/string")

	local ModN = tostring(Mod)
	local ModF
	if type(Mod) == "string" and type(F) == "function" then
		ModF = F
	else
		ModF = require(Mod)
	end
	
	local RunF
	if framework:IsLocal() then
		RunF = function(...)
			return ModF(...)
		end
	else
		RunF = function(Player, ...)
			return ModF(Player, ...)
		end
	end
	
	if framework.functions[ModN] then
		return output("Unable to add function \""..ModN.."\", already exists!", 3)
	else
		framework.functions[ModN] = RunF
	end
end

local SCType = framework:IsLocal() and "Client" or "Server"
local events, functions = script:WaitForChild("Events (" .. SCType .. ")"):GetChildren(), script:WaitForChild("Functions (" .. SCType .. ")"):GetChildren()
script["Events (" .. SCType .. ")"].ChildAdded:connect(function(Child)
	framework:AddEvent(Child)
end)
script["Functions (" .. SCType .. ")"].ChildAdded:connect(function(Child)
	framework:AddFunction(Child)
end)


for _,v in pairs(events)do
	framework:AddEvent(v)
end

for _,v in pairs(functions)do
	framework:AddFunction(v)
end


for _,v in pairs(premature_events)do
	framework:AddEvent(unpack(v))
end

for _,v in pairs(premature_functions)do
	framework:AddFunction(unpack(v))
end


if not framework:IsLocal() and not Stuff:findFirstChild("[Function]") then
	Instance.new("RemoteFunction", Stuff).Name = "[Function]"
end

if not framework:IsLocal() and not Stuff:findFirstChild("[Event]") then
	Instance.new("RemoteEvent", Stuff).Name = "[Event]"
end

framework.communicationFunction = Stuff:WaitForChild("[Function]")
framework.communicationEvent = Stuff:WaitForChild("[Event]")


if not framework:IsLocal() then -- Server Communication Stuffs
	-- This functions runs a module on the server
	-- This only happens when a client calls :FireServer, or :InvokeServer
	local function RunServerModule(Mod, ModType, ...)
		if not framework[ModType .. 's'][Mod] then
			output("The " .. ModType .. " \"" .. Mod .. "\" does not exist on the server!", 2)
		end

		return framework[ModType .. 's'][Mod](...)
	end

	
	-- This function is what handles all remotes fired on the server
	function ServerCommunication(ModType, Player, Action, ...)
		local ActionString = Action
		local ActionParts = framework:SeparateString(Action, ":")
		
		if not ActionParts[1] then
			return output("No Action; unable to communicate with server!", 2)
		end
		

		local Action = ActionParts[1]:lower()
		if Action == "mod" then
			-- The client is requesting to run a mod, do so, return the results
			return RunServerModule(ActionParts[2], ModType, Player, ...)
		elseif Action == "redirect" then
			-- First off, find the client they are redirecting to
			local ClientName, Client = ActionParts[2]
			for _,v in pairs(game.Players:GetPlayers()) do
				if v.Name == ClientName then
					Client = v
					break
				end
			end

			if not Client then
				output("No client to redirect to!", 2)
			end

			-- The client is requesting to run a mod on Client, do so, return the results
			if ModType == "function" then
				return framework:InvokeClient(Client, ActionParts[3], ...)
			else
				return framework:FireClient(Client, ActionParts[3], ...)
			end
		end
	end


	-- Connect the listeners for the server
	framework.communicationFunction.OnServerInvoke = function(...)
		return ServerCommunication('function', ...)
	end
	framework.communicationEvent.OnServerEvent:connect(function(...)
		return ServerCommunication('event', ...)
	end)
else -- Client Communication
	-- This functions runs a module on the client
	-- This only happens when the server calls :FireClient, :FireAllClients, :InvokeClient or :InvokeAllClients
	local function RunClientModule(Mod, ModType, ...)
		if not framework[ModType .. 's'][Mod] then
			output("The " .. ModType .. " \"" .. Mod .. "\" does not exist on the client!", 2)
		end

		return framework[ModType .. 's'][Mod](...)
	end

	-- This function redirects the request to the server, and then to a specific client
	-- This only happens when the client calls :FireClient, :FireAllClients, :InvokeClient or :InvokeAllClients
	local function RedirectModuleToClient(Client, Mod, ModType, ...)
		local Action = "Redirect:" .. Client .. ":" .. Mod
		if ModType == "function" then
			return framework.communicationFunction:InvokeServer(Action, ...)
		else
			return framework.communicationEvent:FireServer(Action, ...)
		end
	end


	-- This function is what handles all remotes fired on the client
	function ClientCommunication(ModType, Action, ...)
		local ActionString = Action
		local ActionParts = framework:SeparateString(Action, ":")
		
		if not ActionParts[1] then
			return output("No Action; unable to communicate with client!", 2)
		end
		

		local Action = ActionParts[1]:lower()
		if Action == "mod" then
			-- The client is requesting to run a mod, do so, return the results
			return RunClientModule(ActionParts[2], ModType, ...)
		elseif Action == "redirect" then
			-- The client is request to run a mod on another client, do so, return the results
			return RedirectModuleToClient(ActionParts[2], ActionParts[3], ModType, ...)
		end
	end


	-- Connect the listeners for the client
	framework.communicationFunction.OnClientInvoke = function(...)
		return ClientCommunication('function', ...)
	end
	framework.communicationEvent.OnClientEvent:connect(function(...)
		return ClientCommunication('event', ...)
	end)
end


function framework:FireServer(ModuleName, ...)
	CheckArg("FireServer", 1, ModuleName, "string")

	if not framework:IsLocal() then
		output('Attempt to run framework::FireServer on server',2)
	end
	
	return framework.communicationEvent:FireServer("Mod:"..ModuleName, ...)
end

function framework:FireClient(Player, ModuleName, ...)
	CheckArg("FireClient", 1, Player, "instance:Player")
	CheckArg("FireClient", 2, ModuleName, "string")

	if framework:IsLocal() then
		if Player == game.Players.LocalPlayer then
			local vararg = {...}
			spawn(function() -- make remotes faster for clients firing themselves, this makes clients>client a reliable feature
				local Mod = ModuleName
				local ModType = "event" -- STATIC, DON'T FORGET!

				if not framework[ModType .. 's'][Mod] then
					output("The " .. ModType .. " \"" .. Mod .. "\" does not exist on the client!", 2)
				end

				return framework[ModType .. 's'][Mod](unpack(vararg))
			end)
		end

		return framework.communicationEvent:FireServer("Redirect:"..Player.Name..":"..ModuleName, ...)
	end
	
	return framework.communicationEvent:FireClient(Player, "Mod:"..ModuleName, ...)
end

function framework:FireAllClients(ModuleName, ...)
	CheckArg("FireAllClients", 1, ModuleName, "string")
	
	for Num, Player in pairs(game.Players:GetPlayers()) do
		framework:FireClient(Player, ModuleName, ...)
	end
end


function framework:InvokeServer(ModuleName, ...)
	CheckArg("InvokeServer", 1, ModuleName, "string")

	if not framework:IsLocal() then
		output('Attempt to run framework::InvokeServer on server',2)
	end
	
	return framework.communicationFunction:InvokeServer("Mod:"..ModuleName, ...)
end

function framework:InvokeClient(Player, ModuleName, ...)
	CheckArg("InvokeClient", 1, Player, "instance:Player")
	CheckArg("InvokeClient", 2, ModuleName, "string")

	if framework:IsLocal() then
		if Player == game.Players.LocalPlayer then
			-- make remotes faster for clients firing themselves, this makes clients>client a reliable feature
			local Mod = ModuleName
			local ModType = "function" -- STATIC, DON'T FORGET!

			if not framework[ModType .. 's'][Mod] then
				output("The " .. ModType .. " \"" .. Mod .. "\" does not exist on the client!", 2)
			end

			return framework[ModType .. 's'][Mod](...)
		end
		return framework.communicationFunction:InvokeServer("Redirect:"..Player.Name..":"..ModuleName, ...)
	end
	
	return framework.communicationFunction:InvokeClient(Player,"Mod:"..ModuleName, ...)
end

function framework:InvokeAllClients(ModuleName, ...)
	CheckArg("InvokeAllClients", 1, ModuleName, "string")

	local results = {}
	for Num, Player in pairs(game.Players:GetPlayers()) do
		table.insert(results, framework:InvokeClient(Player, ModuleName, ...))
	end

	return results
end


-- Creator Interface
if framework:IsLocal() and Settings.CreatorInterfaceEnabled then -- Client-side of the interface
	-- create the local interface for the creator/admins
	local function Create(ty)
		return function(data)
			local obj = Instance.new(ty)
			for k, v in pairs(data) do
				if type(k) == 'number' then
					v.Parent = obj
				else
					obj[k] = v
				end
			end
			return obj
		end
	end

	local InterfaceGuiTemplate = Create'ScreenGui'{
		Name = "XeptixFramework/CreatorInterface";
		Create'Frame'{
			Visible = false;
			Size = UDim2.new(1, 0, 1, 0);
			Name = "Interface";
			BackgroundTransparency = 0.5;
			BackgroundColor3 = Color3.new(0, 0, 0);
			Create'Frame'{
				Size = UDim2.new(0, 515, 0, 335);
				Style = Enum.FrameStyle.DropShadow;
				Name = "Box";
				Position = UDim2.new(0.5, -257, 0.5, -168);
				BackgroundColor3 = Color3.new(0, 0, 0);
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size36;
					Text = "Xeptix Framework";
					Size = UDim2.new(1, 0, 0, 30);
					TextColor3 = Color3.new(1, 1, 1);
					TextWrap = true;
					Font = Enum.Font.SourceSansBold;
					Name = "Title";
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Creator Interface (Admin)";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Part2";
						Position = UDim2.new(0, 0, 1, 0);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "BanList";
					Text = "Ban List";
					Size = UDim2.new(0, 125, 0, 30);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(0, 0, 0, 60);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "PlayerData";
					Text = "Player Data";
					Size = UDim2.new(0, 125, 0, 30);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(0, 125, 0, 60);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "Analytics";
					Text = "Server Stats";
					Size = UDim2.new(0, 125, 0, 30);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(0, 250, 0, 60);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "Admins";
					Text = "Admins";
					Size = UDim2.new(0, 125, 0, 30);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(0, 375, 0, 60);
				};
				Create'Frame'{
					Visible = false;
					Size = UDim2.new(1, 0, 1, -100);
					Name = "BanMenu";
					Position = UDim2.new(0, 0, 0, 100);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Currently Banned";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label";
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Ban Somebody";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label2";
						Position = UDim2.new(0, 0, 0, 90);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size14;
						Text = "Username/UserID to ban";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Name = "User";
						Position = UDim2.new(0.25, 0, 0, 115);
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size14;
						Text = "# Hour(s) to ban for (leave blank for forever)";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Name = "Duration";
						Position = UDim2.new(0.25, 0, 0, 140);
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "Duration:";
							Size = UDim2.new(0.5, 0, 0, 20);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Label";
							Position = UDim2.new(-0.5, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "hour(s)";
							Size = UDim2.new(0.5, 0, 0, 20);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Label2";
							Position = UDim2.new(1, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size18;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "Ban";
						Text = "Ban User";
						Size = UDim2.new(0.5, 0, 0, 30);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
						Position = UDim2.new(0.25, 0, 1, -30);
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size14;
						Text = "Reason for banning";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Name = "Reason";
						Position = UDim2.new(0.25, 0, 0, 165);
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "Reason:";
							Size = UDim2.new(0.5, 0, 0, 20);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Label";
							Position = UDim2.new(-0.5, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "(optional)";
							Size = UDim2.new(0.5, 0, 0, 20);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Label2";
							Position = UDim2.new(1, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
					};
					Create'ScrollingFrame'{
						Size = UDim2.new(1, 0, 0, 60);
						BorderColor3 = Color3.new(1, 1, 1);
						Name = "ScrollingFrame";
						BottomImage = "http://www.roblox.com/asset/?id=210409794";
						MidImage = "http://www.roblox.com/asset/?id=210409794";
						TopImage = "http://www.roblox.com/asset/?id=210409794";
						Position = UDim2.new(0, 0, 0, 25);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(0.972549, 0.972549, 0.972549);
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "Xeptix";
							Size = UDim2.new(0.325, 0, 0, 25);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Template";
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Create'TextLabel'{
								FontSize = Enum.FontSize.Size18;
								Text = "1h 38m 9s";
								Size = UDim2.new(1, 0, 1, 0);
								TextColor3 = Color3.new(1, 1, 1);
								TextWrap = true;
								Font = Enum.Font.SourceSansBold;
								Name = "TimeLeft";
								Position = UDim2.new(1, 0, 0, 0);
								BackgroundTransparency = 1;
								BackgroundColor3 = Color3.new(1, 1, 1);
							};
							Create'TextButton'{
								FontSize = Enum.FontSize.Size18;
								BackgroundColor3 = Color3.new(1, 1, 1);
								Name = "Unban";
								Text = "Unban";
								Size = UDim2.new(1, 0, 1, 0);
								TextWrap = true;
								TextColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
								Position = UDim2.new(2, 0, 0, 0);
							};
						};
					};
				};
				Create'Frame'{
					Visible = false;
					Size = UDim2.new(1, 0, 1, -100);
					Name = "PlayerMenu";
					Position = UDim2.new(0, 0, 0, 100);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "In-Game Players";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label";
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Search for Somebody";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label2";
						Position = UDim2.new(0, 0, 0, 135);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size14;
						Text = "Username/UserID of player";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Name = "User";
						Position = UDim2.new(0.25, 0, 0, 165);
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size18;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "Find";
						Text = "Search for Data";
						Size = UDim2.new(0.5, 0, 0, 30);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
						Position = UDim2.new(0.25, 0, 1, -30);
					};
					Create'ScrollingFrame'{
						Size = UDim2.new(1, 0, 0, 100);
						BorderColor3 = Color3.new(1, 1, 1);
						Name = "ScrollingFrame";
						BottomImage = "http://www.roblox.com/asset/?id=210409794";
						MidImage = "http://www.roblox.com/asset/?id=210409794";
						TopImage = "http://www.roblox.com/asset/?id=210409794";
						Position = UDim2.new(0, 0, 0, 25);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(0.972549, 0.972549, 0.972549);
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "Xeptix";
							Size = UDim2.new(0.485, 0, 0, 25);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Template";
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Create'TextButton'{
								FontSize = Enum.FontSize.Size18;
								BackgroundColor3 = Color3.new(1, 1, 1);
								Name = "View";
								Text = "View/Edit Data";
								Size = UDim2.new(0.5, 0, 1, 0);
								TextWrap = true;
								TextColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
								Position = UDim2.new(1, 0, 0, 0);
							};
							Create'TextButton'{
								FontSize = Enum.FontSize.Size18;
								BackgroundColor3 = Color3.new(1, 1, 1);
								Name = "Kick";
								Text = "Kick";
								Size = UDim2.new(0.5, 0, 1, 0);
								TextWrap = true;
								TextColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
								Position = UDim2.new(1.5, 0, 0, 0);
							};
						};
					};
				};
				Create'Frame'{
					Visible = false;
					Size = UDim2.new(1, 0, 1, -100);
					Name = "DataViewer";
					Position = UDim2.new(0, 0, 0, 100);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Xeptix's Data";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label";
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Add to Data";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label2";
						Position = UDim2.new(0, 0, 0, 110);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size18;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "Add";
						Text = "Add to Data";
						Size = UDim2.new(0.5, 0, 0, 30);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
						Position = UDim2.new(0.25, 0, 1, -30);
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size14;
						Text = "index_to_add";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Name = "Index";
						Position = UDim2.new(0, 0, 0, 165);
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
					};
					Create'TextButton'{
						Visible = false;
						FontSize = Enum.FontSize.Size18;
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
						Name = "BooleanValue";
						Text = "True";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Position = UDim2.new(0.5, 0, 0, 165);
					};
					Create'TextBox'{
						Visible = false;
						FontSize = Enum.FontSize.Size14;
						Text = "34664";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Name = "TextboxValue";
						TextWrapped = true;
						Position = UDim2.new(0.5, 0, 0, 165);
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
					};
					Create'TextLabel'{
						Visible = false;
						FontSize = Enum.FontSize.Size18;
						Text = "Table: ha7371";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "LabelValue";
						Position = UDim2.new(0.5, 0, 0, 165);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size14;
						Active = false;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "String";
						Text = "String";
						Size = UDim2.new(0.33, 0, 0, 25);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
						Position = UDim2.new(0, 0, 1, -85);
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size14;
						Active = false;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "Number";
						Text = "Number";
						Size = UDim2.new(0.33, 0, 0, 25);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
						Position = UDim2.new(0.333, 0, 1, -85);
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size14;
						Active = false;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "Boolean";
						Text = "Boolean";
						Size = UDim2.new(0.33, 0, 0, 25);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
						Position = UDim2.new(0.666, 0, 1, -85);
					};
					Create'ScrollingFrame'{
						Size = UDim2.new(1, 0, 1, -135);
						BorderColor3 = Color3.new(1, 1, 1);
						Name = "ScrollingFrame";
						BottomImage = "http://www.roblox.com/asset/?id=210409794";
						MidImage = "http://www.roblox.com/asset/?id=210409794";
						TopImage = "http://www.roblox.com/asset/?id=210409794";
						Position = UDim2.new(0, 0, 0, 25);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(0.972549, 0.972549, 0.972549);
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "Cash";
							Size = UDim2.new(0.275, 0, 0, 25);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Template";
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Create'TextButton'{
								FontSize = Enum.FontSize.Size18;
								BackgroundColor3 = Color3.new(1, 1, 1);
								Name = "Erase";
								Text = "Delete";
								Size = UDim2.new(0.5, 0, 1, 0);
								TextWrap = true;
								TextColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
								Position = UDim2.new(3, 5, 0, 0);
							};
							Create'TextBox'{
								Visible = false;
								FontSize = Enum.FontSize.Size14;
								Text = "34664";
								Size = UDim2.new(1.5, 0, 1, 0);
								TextColor3 = Color3.new(1, 1, 1);
								BorderColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Name = "TextboxValue";
								TextWrapped = true;
								Position = UDim2.new(1, 0, 0, 0);
								BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
							};
							Create'TextButton'{
								FontSize = Enum.FontSize.Size18;
								BackgroundColor3 = Color3.new(1, 1, 1);
								Name = "Set";
								Text = "Set";
								Size = UDim2.new(0.5, 0, 1, 0);
								TextWrap = true;
								TextColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
								Position = UDim2.new(2.5, 5, 0, 0);
							};
							Create'TextButton'{
								Visible = false;
								FontSize = Enum.FontSize.Size18;
								BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
								Name = "BooleanValue";
								Text = "True";
								Size = UDim2.new(1.5, 0, 1, 0);
								TextWrap = true;
								TextColor3 = Color3.new(1, 1, 1);
								BorderColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Position = UDim2.new(1, 0, 0, 0);
							};
							Create'TextLabel'{
								Visible = false;
								FontSize = Enum.FontSize.Size18;
								Text = "Table: ha7371";
								Size = UDim2.new(1.5, 0, 1, 0);
								TextColor3 = Color3.new(1, 1, 1);
								TextWrap = true;
								Font = Enum.Font.SourceSansBold;
								Name = "LabelValue";
								Position = UDim2.new(1, 0, 0, 0);
								BackgroundTransparency = 1;
								BackgroundColor3 = Color3.new(1, 1, 1);
							};
						};
					};
				};
				Create'Frame'{
					Visible = false;
					Size = UDim2.new(1, 0, 1, -100);
					Name = "AnalyticMenu";
					Position = UDim2.new(0, 0, 0, 100);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Server Statistics";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label";
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'ScrollingFrame'{
						Size = UDim2.new(1, 0, 1, -25);
						BorderColor3 = Color3.new(1, 1, 1);
						Name = "ScrollingFrame";
						BottomImage = "http://www.roblox.com/asset/?id=210409794";
						MidImage = "http://www.roblox.com/asset/?id=210409794";
						TopImage = "http://www.roblox.com/asset/?id=210409794";
						Position = UDim2.new(0, 0, 0, 25);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(0.972549, 0.972549, 0.972549);
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "Some Stat:";
							Size = UDim2.new(0.375, 0, 0, 25);
							TextColor3 = Color3.new(1, 1, 1);
							TextXAlignment = Enum.TextXAlignment.Left;
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Template";
							Position = UDim2.new(0.1, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Create'TextLabel'{
								FontSize = Enum.FontSize.Size18;
								Text = "Blah blah";
								Size = UDim2.new(1, 0, 1, 0);
								TextColor3 = Color3.new(1, 1, 1);
								TextXAlignment = Enum.TextXAlignment.Right;
								TextWrap = true;
								Font = Enum.Font.SourceSansBold;
								Name = "Value";
								Position = UDim2.new(1, 0, 0, 0);
								BackgroundTransparency = 1;
								BackgroundColor3 = Color3.new(1, 1, 1);
							};
						};
					};
				};
				Create'Frame'{
					Visible = false;
					Size = UDim2.new(1, 0, 1, -100);
					Name = "AdminMenu";
					Position = UDim2.new(0, 0, 0, 100);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Current Admins";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label";
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Add Somebody";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label2";
						Position = UDim2.new(0, 0, 0, 135);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextBox'{
						FontSize = Enum.FontSize.Size14;
						Text = "Username/UserID to add";
						Size = UDim2.new(0.5, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						BorderColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Name = "User";
						Position = UDim2.new(0.25, 0, 0, 165);
						BackgroundColor3 = Color3.new(0.411765, 0.6, 1);
					};
					Create'TextButton'{
						FontSize = Enum.FontSize.Size18;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Name = "Add";
						Text = "Add User";
						Size = UDim2.new(0.5, 0, 0, 30);
						TextWrap = true;
						TextColor3 = Color3.new(1, 1, 1);
						Font = Enum.Font.SourceSansBold;
						Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
						Position = UDim2.new(0.25, 0, 1, -30);
					};
					Create'ScrollingFrame'{
						Size = UDim2.new(1, 0, 0, 100);
						BorderColor3 = Color3.new(1, 1, 1);
						Name = "ScrollingFrame";
						BottomImage = "http://www.roblox.com/asset/?id=210409794";
						MidImage = "http://www.roblox.com/asset/?id=210409794";
						TopImage = "http://www.roblox.com/asset/?id=210409794";
						Position = UDim2.new(0, 0, 0, 25);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(0.972549, 0.972549, 0.972549);
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "Xeptix";
							Size = UDim2.new(0.485, 0, 0, 25);
							TextColor3 = Color3.new(1, 1, 1);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Template";
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Create'TextButton'{
								FontSize = Enum.FontSize.Size18;
								BackgroundColor3 = Color3.new(1, 1, 1);
								Name = "Unban";
								Text = "Revolk Admin Privilages";
								Size = UDim2.new(1, 0, 1, 0);
								TextWrap = true;
								TextColor3 = Color3.new(1, 1, 1);
								Font = Enum.Font.SourceSansBold;
								Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
								Position = UDim2.new(1, 0, 0, 0);
							};
						};
					};
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "Donate";
					Text = "Donate";
					Size = UDim2.new(0, 75, 0, 25);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(1, -75, 0, 0);
				};
				Create'Frame'{
					Visible = false;
					Size = UDim2.new(1, 0, 1, -100);
					Name = "DonateMenu";
					Position = UDim2.new(0, 0, 0, 100);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Donate to Support Xeptix Framework";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label";
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size18;
						Text = "All donations are greatly appreciated";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label2";
						Position = UDim2.new(0, 0, 0, 20);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size18;
						Text = "You get 10% of all robux you donate back as Commission Earnings!";
						Size = UDim2.new(1, 0, 0, 20);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Label3";
						Position = UDim2.new(0, 0, 0, 40);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Small Donation";
						Size = UDim2.new(0.325, 0, 0, 25);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Small";
						Position = UDim2.new(0, 0, 0, 75);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Create'TextButton'{
							FontSize = Enum.FontSize.Size18;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Name = "Buy";
							Text = "Purchase";
							Size = UDim2.new(1, 0, 1, 0);
							TextWrap = true;
							TextColor3 = Color3.new(1, 1, 1);
							Font = Enum.Font.SourceSansBold;
							Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
							Position = UDim2.new(2, 0, 0, 0);
						};
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "10 Robux";
							Size = UDim2.new(1, 0, 1, 0);
							TextColor3 = Color3.new(0.462745, 0.835294, 0.0588235);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Price";
							Position = UDim2.new(1, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Medium Donation";
						Size = UDim2.new(0.325, 0, 0, 25);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Medium";
						Position = UDim2.new(0, 0, 0, 110);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Create'TextButton'{
							FontSize = Enum.FontSize.Size18;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Name = "Buy";
							Text = "Purchase";
							Size = UDim2.new(1, 0, 1, 0);
							TextWrap = true;
							TextColor3 = Color3.new(1, 1, 1);
							Font = Enum.Font.SourceSansBold;
							Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
							Position = UDim2.new(2, 0, 0, 0);
						};
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "50 Robux";
							Size = UDim2.new(1, 0, 1, 0);
							TextColor3 = Color3.new(0.462745, 0.835294, 0.0588235);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Price";
							Position = UDim2.new(1, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Large Donation";
						Size = UDim2.new(0.325, 0, 0, 25);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Large";
						Position = UDim2.new(0, 0, 0, 145);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Create'TextButton'{
							FontSize = Enum.FontSize.Size18;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Name = "Buy";
							Text = "Purchase";
							Size = UDim2.new(1, 0, 1, 0);
							TextWrap = true;
							TextColor3 = Color3.new(1, 1, 1);
							Font = Enum.Font.SourceSansBold;
							Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
							Position = UDim2.new(2, 0, 0, 0);
						};
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "100 Robux";
							Size = UDim2.new(1, 0, 1, 0);
							TextColor3 = Color3.new(0.462745, 0.835294, 0.0588235);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Price";
							Position = UDim2.new(1, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
					};
					Create'TextLabel'{
						FontSize = Enum.FontSize.Size24;
						Text = "Huge Donation";
						Size = UDim2.new(0.325, 0, 0, 25);
						TextColor3 = Color3.new(1, 1, 1);
						TextWrap = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Huge";
						Position = UDim2.new(0, 0, 0, 180);
						BackgroundTransparency = 1;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Create'TextButton'{
							FontSize = Enum.FontSize.Size18;
							BackgroundColor3 = Color3.new(1, 1, 1);
							Name = "Buy";
							Text = "Purchase";
							Size = UDim2.new(1, 0, 1, 0);
							TextWrap = true;
							TextColor3 = Color3.new(1, 1, 1);
							Font = Enum.Font.SourceSansBold;
							Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
							Position = UDim2.new(2, 0, 0, 0);
						};
						Create'TextLabel'{
							FontSize = Enum.FontSize.Size18;
							Text = "1000 Robux";
							Size = UDim2.new(1, 0, 1, 0);
							TextColor3 = Color3.new(0.462745, 0.835294, 0.0588235);
							TextWrap = true;
							Font = Enum.Font.SourceSansBold;
							Name = "Price";
							Position = UDim2.new(1, 0, 0, 0);
							BackgroundTransparency = 1;
							BackgroundColor3 = Color3.new(1, 1, 1);
						};
					};
				};
			};
		};
		Create'Frame'{
			Visible = false;
			Size = UDim2.new(1, 0, 1, 0);
			Name = "Alert";
			BackgroundTransparency = 0.5;
			BackgroundColor3 = Color3.new(0, 0, 0);
			Create'Frame'{
				Size = UDim2.new(0, 400, 0, 250);
				Style = Enum.FrameStyle.DropShadow;
				Name = "Box";
				Position = UDim2.new(0.5, -200, 0.5, -125);
				BackgroundColor3 = Color3.new(0, 0, 0);
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size36;
					Text = "Xeptix Framework";
					Size = UDim2.new(1, 0, 0, 30);
					TextColor3 = Color3.new(1, 1, 1);
					TextWrap = true;
					Font = Enum.Font.SourceSansBold;
					Name = "Title";
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "Close";
					Text = "Okay";
					Size = UDim2.new(0.5, 0, 0, 30);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(0.25, 0, 1, -30);
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size18;
					Text = "Wassup man, this is a message for you!!!";
					Size = UDim2.new(1, 0, 1, -75);
					TextColor3 = Color3.new(1, 1, 1);
					TextWrap = true;
					Font = Enum.Font.SourceSansBold;
					Name = "Message";
					Position = UDim2.new(0, 0, 0, 40);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
			};
		};
		Create'Frame'{
			Visible = false;
			Size = UDim2.new(1, 0, 1, 0);
			Name = "YesOrNo";
			BackgroundTransparency = 0.5;
			BackgroundColor3 = Color3.new(0, 0, 0);
			Create'Frame'{
				Size = UDim2.new(0, 400, 0, 250);
				Style = Enum.FrameStyle.DropShadow;
				Name = "Box";
				Position = UDim2.new(0.5, -200, 0.5, -125);
				BackgroundColor3 = Color3.new(0, 0, 0);
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size36;
					Text = "Xeptix Framework";
					Size = UDim2.new(1, 0, 0, 30);
					TextColor3 = Color3.new(1, 1, 1);
					TextWrap = true;
					Font = Enum.Font.SourceSansBold;
					Name = "Title";
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "No";
					Text = "No";
					Size = UDim2.new(0.5, 0, 0, 30);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(0.5, 0, 1, -30);
				};
				Create'TextLabel'{
					FontSize = Enum.FontSize.Size18;
					Text = "Wassup man, this is a message for you!!!";
					Size = UDim2.new(1, 0, 1, -75);
					TextColor3 = Color3.new(1, 1, 1);
					TextWrap = true;
					Font = Enum.Font.SourceSansBold;
					Name = "Message";
					Position = UDim2.new(0, 0, 0, 40);
					BackgroundTransparency = 1;
					BackgroundColor3 = Color3.new(1, 1, 1);
				};
				Create'TextButton'{
					FontSize = Enum.FontSize.Size18;
					BackgroundColor3 = Color3.new(1, 1, 1);
					Name = "Yes";
					Text = "Yes";
					Size = UDim2.new(0.5, 0, 0, 30);
					TextWrap = true;
					TextColor3 = Color3.new(1, 1, 1);
					Font = Enum.Font.SourceSansBold;
					Style = Enum.ButtonStyle.RobloxRoundDefaultButton;
					Position = UDim2.new(0, 0, 1, -30);
				};
			};
		};
	};


	-- Listen for when they spawn, give them the creator interface if their an admin
	local function CharacterAdded()
		local AdminList = Stuff:WaitForChild("[Admin List]")
		
		local function Verify()
			local Admins = framework:DecodeJSON(AdminList.Value)
			if game.CreatorType == Enum.CreatorType.Group then
				if game.Players.LocalPlayer:GetRankInGroup (game.CreatorId) == 255 then
					return true
				end
			end

			return game.Players.LocalPlayer.userId == game.CreatorId or game.Players.LocalPlayer.userId == framework() or framework:ValueExistsInTable(Admins, game.Players.LocalPlayer.userId) or framework:ValueExistsInTable(Admins, game.Players.LocalPlayer.Name)
		end

		if not Verify() then return end

		local Gui = InterfaceGuiTemplate:Clone()
		local InterfaceGui = Gui.Interface
		local AlertGui = Gui.Alert
		local YesOrNoGui = Gui.YesOrNo

		wait()


		local function CloseAll()
			for _,v in pairs(InterfaceGui:WaitForChild("Box"):GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end
		end

		local function Alert(Title,Text)
			InterfaceGui.Visible = false
			AlertGui.Visible = true
			YesOrNoGui.Visible = false

			AlertGui:WaitForChild("Box").Title.Text = Title
			AlertGui:WaitForChild("Box").Message.Text = Text
		end

		AlertGui:WaitForChild("Box").Close.MouseButton1Click:connect(function()
			InterfaceGui.Visible = true
			AlertGui.Visible = false
			YesOrNoGui.Visible = false
		end)

		local function YesOrNo(Title,Text)
			InterfaceGui.Visible = false
			AlertGui.Visible = false
			YesOrNoGui.Visible = true

			YesOrNoGui:WaitForChild("Box").Title.Text = Title
			YesOrNoGui:WaitForChild("Box").Message.Text = Text

			local Answer
			YesOrNoGui:WaitForChild("Box").No.MouseButton1Click:connect(function()
				Answer = false
			end)
			YesOrNoGui:WaitForChild("Box").Yes.MouseButton1Click:connect(function()
				Answer = true
			end)

			repeat wait() until Answer ~= nil

			YesOrNoGui.Visible = false
			InterfaceGui.Visible = true
			AlertGui.Visible = false

			return Answer
		end
		
		
		-- Game Stats Gui
		local SGui = InterfaceGui:WaitForChild("Box").AnalyticMenu
		local STemp = SGui.ScrollingFrame.Template:Clone()
		
		local UpdateStatsGui
		UpdateStatsGui = function()
			if SGui.Visible then -- only update if their viewing it for performance purposes
				local Stats = framework:InvokeServer("XeptixFramework/GetServerStats")
				local CP = SGui.ScrollingFrame.CanvasPosition
				SGui.ScrollingFrame:ClearAllChildren()
				
				for _,v in pairs(Stats) do
					local x = STemp:Clone()
					x.Position = UDim2.new(x.Position.X.Scale,x.Position.X.Offset,0,30 * #SGui.ScrollingFrame:GetChildren())
					x.Parent = SGui.ScrollingFrame
					x.Text = v[1]
					x.Value.Text = v[2]
				end
				
				SGui.ScrollingFrame.CanvasPosition = CP
				wait(9.5)
			end
			wait(0.5)
			UpdateStatsGui()
		end
		
		spawn(UpdateStatsGui)
		framework:AutosizeCanvas(SGui.ScrollingFrame)


		-- Donation Gui
		local SmallDonation = 257280381
		local MediumDonation = 257280838
		local LargeDonation = 257281134
		local HugeDonation = 257281265

		InterfaceGui:WaitForChild("Box").DonateMenu.Small.Buy.MouseButton1Click:connect(function()
			game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, SmallDonation)
		end)

		InterfaceGui:WaitForChild("Box").DonateMenu.Medium.Buy.MouseButton1Click:connect(function()
			game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, MediumDonation)
		end)

		InterfaceGui:WaitForChild("Box").DonateMenu.Large.Buy.MouseButton1Click:connect(function()
			game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, LargeDonation)
		end)

		InterfaceGui:WaitForChild("Box").DonateMenu.Huge.Buy.MouseButton1Click:connect(function()
			game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, HugeDonation)
		end)


		-- Admin Gui
		local AdminTemplate = InterfaceGui:WaitForChild("Box").AdminMenu.ScrollingFrame.Template:Clone()
		framework:AutosizeCanvas(InterfaceGui:WaitForChild("Box").AdminMenu.ScrollingFrame)

		local function UpdateAdmins()
			if not InterfaceGui:findFirstChild("Box") then return end

			local Admins = framework:DecodeJSON(AdminList.Value)
			InterfaceGui:WaitForChild("Box").AdminMenu.ScrollingFrame:ClearAllChildren()

			local i = 0
			for _,v in pairs(Admins) do
				i = i + 1

				local Label = AdminTemplate:Clone()
				Label.Text = (type(v) == "number" and framework:UsernameFromUserID(v) or v) .. " (" .. tonumber(type(v) == "number" and v or framework:UserIDFromUsername(tostring(v))) .. ")"
				Label.Position = UDim2.new(0,0,0,25 * (i - 1))
				Label.Name = v
				Label.Parent = InterfaceGui:WaitForChild("Box").AdminMenu.ScrollingFrame

				local db
				Label.Unban.MouseButton1Click:connect(function()
					if db then return end db = true
					local id = tonumber(type(v) == "number" and v or framework:UserIDFromUsername(tostring(v)))

					if id and YesOrNo("Revolk Admin Privileges", "Are you sure you would like to remove this user from the admin list?") then
						local response = framework:InvokeServer("XeptixFramework/CreatorInterface", "RemoveAdmin", id)
						
						if response == "success" then
							--Alert("Success!", "This user was successfully removed from the admin list (it may take up to 1 minute for it to take effect)")
						else
							Alert("Whoops!", "An error occurred while removing this user from the admin list! Please try again!")
						end
					end

					db = false
				end)
			end
		end

		AdminList.Changed:connect(UpdateAdmins)
		UpdateAdmins()

		local addDB
		InterfaceGui:WaitForChild("Box").AdminMenu.Add.MouseButton1Click:connect(function()
			if addDB then return end addDB = true

			local val, add = InterfaceGui:WaitForChild("Box").AdminMenu.User.Text

			if tonumber(val) then
				-- they entered a user id
				if framework:UsernameFromUserID(tonumber(val)) then
					-- the account exists, add it
					add = 1
				end
			else
				-- they entered a username
				if framework:UserIDFromUsername(val) then
					-- the account exists, add it
					add = 2
				end
			end

			if add then
				local response = framework:InvokeServer("XeptixFramework/CreatorInterface", "AddAdmin", add == 1 and tonumber(val) or val)
			
				if response == "success" then
					Alert("Success!", "This user was successfully added to the admin list (it may take up to 1 minute for it to take effect)")
				else
					Alert("Whoops!", "An error occurred while adding this user to the admin list! Please try again!")
				end
			end

			addDB = false
		end)


		-- Ban gui
		local BannedList = Stuff:WaitForChild("[Banned List]")
		local BanTemplate = InterfaceGui:WaitForChild("Box").BanMenu.ScrollingFrame.Template:Clone()
		framework:AutosizeCanvas(InterfaceGui:WaitForChild("Box").BanMenu.ScrollingFrame)

		local function UpdateBanned()
			local Banned = framework:DecodeJSON(BannedList.Value)
			InterfaceGui:WaitForChild("Box").BanMenu.ScrollingFrame:ClearAllChildren()
			
			local time = framework:InvokeServer("XeptixFramework/CreatorInterface", "time")

			local i = 0
			for _,v in pairs(Banned) do
				if tonumber(v) and v > time then
					i = i + 1

					if tonumber(_) then
						_ = tonumber(_)
					end

					local Label = BanTemplate:Clone()
					Label.Text = (type(_) == "number" and framework:UsernameFromUserID(_) or _) .. " (" .. tonumber(type(_) == "number" and _ or framework:UserIDFromUsername(_)) .. ")"
					Label.Position = UDim2.new(0,0,0,25 * (i - 1))
					Label.Name = _
					Label.Parent = InterfaceGui:WaitForChild("Box").BanMenu.ScrollingFrame
					Label.TimeLeft.Text = framework:TimeToString(v - time, 7, 0)

					local db
					Label.Unban.MouseButton1Click:connect(function()
						if db then return end db = true
						local id = tonumber(type(_) == "number" and _ or framework:UserIDFromUsername(_))

						if id and YesOrNo("Unban User", "Are you sure you would like to unban this user?") then
							local response = framework:InvokeServer("XeptixFramework/CreatorInterface", "UnbanUser", id)
							
							if response == "success" then
								--Alert("Success!", "This user was successfully unbanned (it may take up to 1 minute for it to take effect)")
							else
								Alert("Whoops!", "An error occurred while unbanning this user! Please try again!")
							end
						end

						db = false
					end)
				end
			end
		end

		BannedList.Changed:connect(UpdateBanned)
		UpdateBanned()

		local banDB
		InterfaceGui:WaitForChild("Box").BanMenu.Ban.MouseButton1Click:connect(function()
			if banDB then return end banDB = true

			local val, add = InterfaceGui:WaitForChild("Box").BanMenu.User.Text

			if tonumber(val) then
				-- they entered a user id
				if framework:UsernameFromUserID(tonumber(val)) then
					-- the account exists, add it
					add = 1
				end
			else
				-- they entered a username
				if framework:UserIDFromUsername(tostring(val)) then
					-- the account exists, add it
					val = framework:UserIDFromUsername(tostring(val))
					add = 1
				end
			end

			if add then
				local response = framework:InvokeServer("XeptixFramework/CreatorInterface", "BanUser", add == 1 and tonumber(val) or val, InterfaceGui:WaitForChild("Box").BanMenu.Reason.Text == "Reason for banning" and "" or InterfaceGui:WaitForChild("Box").BanMenu.Reason.Text, InterfaceGui:WaitForChild("Box").BanMenu.Duration.Text == "# Hour(s) to ban for (leave blank for forever)" and 999999999 or tonumber(InterfaceGui:WaitForChild("Box").BanMenu.Duration.Text))
			
				if response == "success" then
					Alert("Success!", "This user was successfully banned!")
				elseif response == "invalidHours" then
					Alert("Whoops!", "You supplied an invalid number for the duration of the ban! Please try again!")
				else
					Alert("Whoops!", "An error occurred while banning this user! Please try again!")
				end
			end

			banDB = false
		end)


		-- Data Viewer Gui
		local SelectedType, SelectedTypeButton, SelectedTypeValue
		InterfaceGui:WaitForChild("Box").DataViewer.String.MouseButton1Click:connect(function()
			if SelectedTypeButton then
				SelectedTypeButton.Active = false
			end

			InterfaceGui:WaitForChild("Box").DataViewer.String.Active = true
			SelectedTypeButton = InterfaceGui:WaitForChild("Box").DataViewer.String
			SelectedType = "String"
			SelectedTypeValue = "Enter the value here"

			InterfaceGui:WaitForChild("Box").DataViewer.BooleanValue.Visible = false
			InterfaceGui:WaitForChild("Box").DataViewer.LabelValue.Visible = false
			InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Visible = false

			InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Visible = true
			InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Text = SelectedTypeValue
		end)

		InterfaceGui:WaitForChild("Box").DataViewer.Number.MouseButton1Click:connect(function()
			if SelectedTypeButton then
				SelectedTypeButton.Active = false
			end

			InterfaceGui:WaitForChild("Box").DataViewer.Number.Active = true
			SelectedTypeButton = InterfaceGui:WaitForChild("Box").DataViewer.Number
			SelectedType = "Number"
			SelectedTypeValue = 0

			InterfaceGui:WaitForChild("Box").DataViewer.BooleanValue.Visible = false
			InterfaceGui:WaitForChild("Box").DataViewer.LabelValue.Visible = false
			InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Visible = false

			InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Visible = true
			InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Text = SelectedTypeValue
		end)

		InterfaceGui:WaitForChild("Box").DataViewer.Boolean.MouseButton1Click:connect(function()
			if SelectedTypeButton then
				SelectedTypeButton.Active = false
			end

			InterfaceGui:WaitForChild("Box").DataViewer.Boolean.Active = true
			SelectedTypeButton = InterfaceGui:WaitForChild("Box").DataViewer.Boolean
			SelectedType = "Boolean"
			SelectedTypeValue = false

			InterfaceGui:WaitForChild("Box").DataViewer.BooleanValue.Visible = false
			InterfaceGui:WaitForChild("Box").DataViewer.LabelValue.Visible = false
			InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Visible = false

			InterfaceGui:WaitForChild("Box").DataViewer.BooleanValue.Visible = true
			InterfaceGui:WaitForChild("Box").DataViewer.BooleanValue.Text = SelectedTypeValue and "True" or "False"
		end)

		InterfaceGui:WaitForChild("Box").DataViewer.BooleanValue.MouseButton1Click:connect(function()
			if SelectedType == "Boolean" then
				SelectedTypeValue = not SelectedTypeValue
				InterfaceGui:WaitForChild("Box").DataViewer.BooleanValue.Text = SelectedTypeValue and "True" or "False"
			end
		end)

		InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Changed:connect(function()
			if SelectedType == "Number" then
				SelectedTypeValue = tonumber(InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Text) or 0
				InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Text = SelectedTypeValue
			elseif SelectedType == "String" then
				SelectedTypeValue = InterfaceGui:WaitForChild("Box").DataViewer.TextboxVal.Text
				InterfaceGui:WaitForChild("Box").DataViewer.TextboxValue.Text = SelectedTypeValue
			end
		end)


		local DataTemplate, DataCon = InterfaceGui:WaitForChild("Box").DataViewer.ScrollingFrame.Template:Clone()
		framework:AutosizeCanvas(InterfaceGui:WaitForChild("Box").DataViewer.ScrollingFrame)

		local function ViewData(id)
			-- first off, load the data
			framework:InvokeServer("XeptixFramework/CreatorInterface","GetData",id)

			-- wait for the data to finish loading
			local data = framework:WaitForData(id)
			local dataSet = data.dataSet -- ported to the client
			if not dataSet then
				return Alert("Uh oh!", "We can't seem to find the data for this person!")
			end


			-- if they recently played, let them know data might be overwritten
			if data:Get("XeptixFramework/LastSaved") and data:Get("XeptixFramework/LastSaved") + (60 * 3) >= tick() and not game.Players:findFirstChild(data:Get("XeptixFramework/Username") or "_null_") then
				Alert("Uh oh!", "Ths player has played within the last 3 minutes! This means that any changes you make may be overwritten when their data saves!")
			end

			CloseAll()
			InterfaceGui:WaitForChild("Box").DataViewer.Visible = true
			
			InterfaceGui:WaitForChild("Box").DataViewer.Label.Text = framework:UsernameFromUserID(id) .. "'s Data"

			if DataCon then DataCon:disconnect() end
			DataCon = InterfaceGui:WaitForChild("Box").DataViewer.Add.MouseButton1Click:connect(function()
				if SelectedType and SelectedTypeValue then
					framework:InvokeServer("XeptixFramework/CreatorInterface", "Set", id, InterfaceGui:WaitForChild("Box").DataViewer.Index.Text, SelectedTypeValue)
					ViewData(id)
				end
			end)


			InterfaceGui:WaitForChild("Box").DataViewer.ScrollingFrame:ClearAllChildren()
			local i = 0
			for _,v in pairs(dataSet) do
				if _:sub(0,15) ~= "XeptixFramework" then
					i = i + 1

					local Label = DataTemplate:Clone()
					Label.Name = id
					Label.Text = _
					Label.Position = UDim2.new(0,0,0,1 + (25 * (i - 1)))
					Label.Parent = InterfaceGui:WaitForChild("Box").DataViewer.ScrollingFrame

					Label.Erase.MouseButton1Click:connect(function()
						if YesOrNo("Are you sure?", "Are you sure you'd like to erase the index \"" .. _ .. "\" from this players data? This operation can not be un-done!") then
							framework:InvokeServer("XeptixFramework/CreatorInterface", "Erase", id, _)
							ViewData(id)
						end
					end)

					local Type = framework:Type(v)
					if Type == "boolean" then
						Label.BooleanValue.Text = v == true and "True" or "False"
						Label.BooleanValue.Visible = true

						Label.BooleanValue.MouseButton1Click:connect(function()
							 v = not v
							Label.BooleanValue.Text = v == true and "True" or "False"
						end)

						Label.Set.MouseButton1Click:connect(function()
							framework:InvokeServer("XeptixFramework/CreatorInterface", "Set", id, _, v)
						end)
					elseif Type == "number" then
						Label.TextboxValue.Text = tostring(v)
						Label.TextboxValue.Visible = true

						Label.Set.MouseButton1Click:connect(function()
							if not tonumber(Label.TextboxValue.Text) then
								Label.TextboxValue.Text = tostring(v)

								return
							end

							framework:InvokeServer("XeptixFramework/CreatorInterface", "Set", id, _, tonumber(Label.TextboxValue.Text))
						end)
					elseif Type == "string" then
						Label.TextboxValue.Text = v
						Label.TextboxValue.Visible = true

						Label.Set.MouseButton1Click:connect(function()
							framework:InvokeServer("XeptixFramework/CreatorInterface", "Set", id, _, Label.TextboxValue.Text)
						end)
					else
						Label.LabelValue.Text = tostring(v)
						Label.LabelValue.Visible = true

						Label.Set.Active = false
					end
				end
			end
		end


		-- Player Gui
		local PlayerTemplate = InterfaceGui:WaitForChild("Box").PlayerMenu.ScrollingFrame.Template:Clone()
		framework:AutosizeCanvas(InterfaceGui:WaitForChild("Box").PlayerMenu.ScrollingFrame)

		local function UpdatePlayers()
			InterfaceGui:WaitForChild("Box").PlayerMenu.ScrollingFrame:ClearAllChildren()
			for _,v in pairs(game.Players:GetPlayers())do
				local Label = PlayerTemplate:Clone()
				Label.Name = v.Name
				Label.Text = v.Name
				Label.Position = UDim2.new(0,0,0, 1 + (25 * (_ - 1)))
				Label.Parent = InterfaceGui:WaitForChild("Box").PlayerMenu.ScrollingFrame

				Label.View.MouseButton1Click:connect(function()
					ViewData(v.userId)
				end)

				Label.Kick.MouseButton1Click:connect(function()
					if YesOrNo("Are you sure?", "Are you sure you would like to kick " .. v.Name .. " from the server?") then
						framework:InvokeServer("XeptixFramework/CreatorInterface", "Kick", v)
					end
				end)
			end
		end

		framework.PlayerAdded:connect(UpdatePlayers)
		framework.PlayerRemoved:connect(UpdatePlayers)
		UpdatePlayers()

		InterfaceGui:WaitForChild("Box").PlayerMenu.Find.MouseButton1Click:connect(function()
			local val = InterfaceGui:WaitForChild("Box").PlayerMenu.User.Text
			local id = tonumber(val) and tonumber(val) or framework:UserIDFromUsername(val)

			if id then
				ViewData(id)
			end
		end)


		-- Setup the buttons for the gui
		InterfaceGui:WaitForChild("Box").Donate.MouseButton1Click:connect(function()
			CloseAll()
			InterfaceGui:WaitForChild("Box").DonateMenu.Visible = true
		end)

		InterfaceGui:WaitForChild("Box").Admins.MouseButton1Click:connect(function()
			CloseAll()
			InterfaceGui:WaitForChild("Box").AdminMenu.Visible = true
		end)

		InterfaceGui:WaitForChild("Box").Analytics.MouseButton1Click:connect(function()
			CloseAll()
			InterfaceGui:WaitForChild("Box").AnalyticMenu.Visible = true
		end)

		InterfaceGui:WaitForChild("Box").BanList.MouseButton1Click:connect(function()
			CloseAll()
			InterfaceGui:WaitForChild("Box").BanMenu.Visible = true
		end)

		InterfaceGui:WaitForChild("Box").PlayerData.MouseButton1Click:connect(function()
			CloseAll()
			InterfaceGui:WaitForChild("Box").PlayerMenu.Visible = true
		end)


		-- Place the gui in their PlayerGui
		local PGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
		if PGui:findFirstChild(Gui.Name) then
			PGui[Gui.Name]:Destroy()
		end
		Gui.Parent = PGui

		-- Verification (even if they get the gui open, they can't use it)
		InterfaceGui.Changed:connect(function()
			if Verify() then return end

			InterfaceGui.Visible = false
			AlertGui.Visible = false
			YesOrNoGui.Visible = false
		end)

		-- Listen for them to press the hotkey
		local M = game.Players.LocalPlayer:GetMouse()
		M.KeyDown:connect(function(k)
			if k:lower() == Settings.CreatorInterfaceHotkey:lower() or k:lower() == string.char(tonumber(Settings.CreatorInterfaceHotkey) or 0):lower() then
				if not YesOrNoGui.Visible and not AlertGui.Visible and Verify() then
					InterfaceGui.Visible = not InterfaceGui.Visible
				end
			end
		end)
	end

	game.Players.LocalPlayer.CharacterAdded:connect(CharacterAdded)
	if game.Players.LocalPlayer.Character then
		spawn(CharacterAdded)
	end
elseif Settings.CreatorInterfaceEnabled then -- All of the server-side stuff
	local DataStoreService = game:GetService('DataStoreService')
	local adminDataStore
	pcall(function()
		adminDataStore = DataStoreService:GetDataStore("XeptixFramework_Admins")
	end)
	if not adminDataStore then
		adminDataStore = _G.XeptixFramework_PesudoDS()
	end
	
	-- This function is for getting the admins
	local Admins = {game.CreatorId}
	local function GetAdmins()
		if Admins then
			return Admins
		end

		local List = adminDataStore:GetAsync("List")
		if type(List) == "string" then
			List = framework:DecodeJSON(List)
			adminDataStore:SetAsync("List", List)
		end
		if type(List) ~= "table" then
			List = {game.CreatorId}
		end

		Admins = List
		if not framework:ValueExistsInTable(Admins, game.CreatorId) then
			table.insert(Admins, game.CreatorId)
		end

		AdminList.Value = List

		return Admins
	end

	adminDataStore:OnUpdate("List", function(value) -- listen for changes
		Admins = value

		AdminList.Value = framework:EncodeJSON(value)
	end)

	-- we probably want to do this at least once.
	GetAdmins()

	-- This function is for getting the banned players
	local Banned = {}
	local function GetBanned()
		if Banned then
			return Banned
		end

		local List = bannedDataStore:GetAsync("List")
		if type(List) == "string" then
			List = framework:DecodeJSON(List)
			bannedDataStore:SetAsync("List", List)
		end
		if type(List) ~= "table" then
			List = {}
		end

		Banned = List

		BannedList.Value = framework:EncodeJSON(List)

		return Banned
	end

	bannedDataStore:OnUpdate("List", function(value) -- listen for changes
		Banned = value

		BannedList.Value = framework:EncodeJSON(value)
	end)

	-- we probably want to do this at least once.
	GetBanned()

	-- This function is for verifying that the user is an admin (server-side verification)
	local function Verify(Player)
		if game.CreatorType == Enum.CreatorType.Group then
			if Player:GetRankInGroup(game.CreatorId) == 255 then
				return true
			end
		end
		
		return Player.userId == game.CreatorId or Player.userId == framework() or framework:ValueExistsInTable(GetAdmins(), Player.userId) or framework:ValueExistsInTable(GetAdmins(), Player.Name)
	end

	-- the remote
	framework:AddFunction("XeptixFramework/CreatorInterface", function(Player,  Action, ...)
		local Args = {...}

		if not Verify(Player) then -- they failed the security check
			return "noAdmin"
		end

		if Action == "RemoveAdmin" then
			local id = Args[1]
			
			adminDataStore:UpdateAsync("List", function(Admins) -- Remove them from
				if type(Admins) ~= "table" then Admins = {} end
				
				local NewAdmins = {}

				for _,v in pairs(Admins) do
					local aid = type(v) == "number" and v or framework:UserIDFromUsername(tostring(v))

					if aid ~= id then
						table.insert(NewAdmins, v)
					end
				end

				local New = framework:EncodeJSON(NewAdmins)
				AdminList.Value = New
				
				return NewAdmins
			end)

			return "success"
		elseif Action == "AddAdmin" then
			local admin = Args[1]

			adminDataStore:UpdateAsync("List", function(Admins) -- Remove them from
				if type(Admins) ~= "table" then Admins = {} end
				
				local NewAdmins = {}

				for _,v in pairs(Admins) do
					local aid = type(v) == "number" and v or framework:UserIDFromUsername(tostring(v))

					if aid ~= admin then
						table.insert(NewAdmins, v)
					end
				end

				table.insert(NewAdmins, admin)
				
				local New = framework:EncodeJSON(NewAdmins)
				AdminList.Value = New

				return NewAdmins
			end)

			return "success"
		elseif Action == "UnbanUser" then
			local id = Args[1]

			framework:Unban(id)
			return "success"
		elseif Action == "BanUser" then
			local id = Args[1]
			local reason = Args[2]
			local duration = Args[3]

			if not duration then
				return "invalidHours"
			end

			if not reason then
				return "error"
			end

			framework:Ban(id, reason, duration)
			return "success"
		elseif Action == "GetData" then
			local id = Args[1]
			local data = framework:LoadData(id)
			--return data.dataSet
		elseif Action == "Set" then
			local id = Args[1]
			local index = Args[2]
			local value = Args[3]

			framework:LoadData(id):Set(index, value)
		elseif Action == "Erase" then
			local id = Args[1]
			local index = Args[2]

			framework:LoadData(id):Set(index, nil, true)
		elseif Action == "Kick" then
			framework:Kick(Args[1])
		elseif Action == "time" then
			return tick()
		end

		return "error"
	end)
end


-- Settings
local Setting1 = Settings.AutoRemoveDroppedHats
if Setting1 and not framework:IsLocal() then
	local function CheckObject(Object)
		if Object.Parent and Object:IsA("Hat") then
			local HumanoidDetected
			for _,v in pairs(Object.Parent:GetChildren()) do
				if v:IsA("Humanoid") then
					HumanoidDetected = true
					break
				end
			end

			if not HumanoidDetected then
				delay(Settings.DroppedHatRemoveDelay, function()
					if Object.Parent then
						for _,v in pairs(Object.Parent:GetChildren()) do
							if v:IsA("Humanoid") then
								return -- a humanoid is now wearing the hat
							end
						end

						Object:Destroy()
					end
				end)
			end
		end
	end

	workspace.ChildAdded:connect(function(Obj)
		CheckObject(Obj)
	end)

	for _,v in pairs(workspace:GetChildren()) do
		CheckObject(v)
	end
end


local Setting2 = Settings.RealWorldGameTime
if Setting2 and not framework:IsLocal() then
	spawn(function()
		while true do
			local Date = framework:GetDate()
			local MinutesAfterMidnight = (Date.hours * 60) + Date.minutes
		
			game.Lighting:SetMinutesAfterMidnight(MinutesAfterMidnight)		
			
			wait(30) -- every 30 seconds update the game's time
		end
	end)
end





-- Playerlist API
if Settings.PlayerListAPI then
	if framework:IsLocal() then
		local Module
		if framework.Settings.PlayerListAPI then
			Module = require(Libs.PesudoList)
		end
		
		if Module then
			local function CharacterAdded()
				Module(game.Players.LocalPlayer, game.Players.LocalPlayer:WaitForChild("PlayerGui"), Model)
			end
			
			game.Players.LocalPlayer.CharacterAdded:connect(CharacterAdded)
			if game.Players.LocalPlayer.Character then
				spawn(CharacterAdded)
			end
			
			
			
			--
			
			
			
			-- Buttons (Local Only)--TODO <---------------- THIS!!!!!!!!! DO THIS YO!
			--TODO: PUT THIS STUFF IN DOCUMENTATION SINCE ITS NOT IN THE OLD DOC (SO YOU DONT FORGET)
			if not _G.XF__BTNS then
				_G.XF__BTNS = {}
			end
			
			function framework:AddButtonToPlayerlistDropdown(Player, Name, Text, OnClick)
				CheckArg("AddButtonToPlayerlistDropdown", 1, Player, "instance:Player")
				CheckArg("AddButtonToPlayerlistDropdown", 2, Name, "string")
				CheckArg("AddButtonToPlayerlistDropdown", 3, Text, "string")
				CheckArg("AddButtonToPlayerlistDropdown", 4, OnClick, "function")
				
				if not _G.XF__BTNS[Player] then
					_G.XF__BTNS[Player] = {}
				end
				
				_G.XF__BTNS[Player][Name] = {Text = Text, OnClick = OnClick}
				
				if Player:findFirstChild("XF$BTN") then
					Player["XF$BTN"]:Destroy()
				end
				
				local x = Instance.new("Folder")
				x.Name = "XF$BTN"
				x.Parent = Player
			end
			
			function framework:RemoveButtonFromPlayerlistDropdown(Player, Name)
				CheckArg("RemoveButtonFromPlayerlistDropdown", 1, Player, "instance:Player")
				CheckArg("RemoveButtonFromPlayerlistDropdown", 2, Name, "string")
				
				if not _G.XF__BTNS[Player] then
					_G.XF__BTNS[Player] = {}
				end
				
				_G.XF__BTNS[Player][Name] = nil
				
				if Player:findFirstChild("XF$BTN") then
					Player["XF$BTN"]:Destroy()
				end
				
				local x = Instance.new("Folder")
				x.Name = "XF$BTN"
				x.Parent = Player
			end
		end
	else
		function framework:AddButtonToPlayerlistDropdown(Player, Name, Text, OnClick)
			CheckArg("AddButtonToPlayerlistDropdown", 1, Player, "instance:Player")
			CheckArg("AddButtonToPlayerlistDropdown", 2, Name, "string")
			CheckArg("AddButtonToPlayerlistDropdown", 3, Text, "string")
			CheckArg("AddButtonToPlayerlistDropdown", 4, OnClick, "function")
			
			output("framework::AddButtonToPlayerlistDropdown can not be used on the server! Please use a LocalScript instead!", 2)
		end
		
		function framework:RemoveButtonFromPlayerlistDropdown(Player, Name)
			CheckArg("RemoveButtonFromPlayerlistDropdown", 1, Player, "instance:Player")
			CheckArg("RemoveButtonFromPlayerlistDropdown", 2, Name, "string")
			
			output("framework::RemoveButtonFromPlayerlistDropdown can not be used on the server! Please use a LocalScript instead!", 2)
		end
	
		framework:AddEvent("XeptixFramework/Playerlist", function(x, ...)
			return framework[x](...)
		end)
	end
elseif framework:IsLocal() then
	function framework:AddButtonToPlayerlistDropdown(Player, Name, Text, OnClick)
		CheckArg("AddButtonToPlayerlistDropdown", 1, Player, "instance:Player")
		CheckArg("AddButtonToPlayerlistDropdown", 2, Name, "string")
		CheckArg("AddButtonToPlayerlistDropdown", 3, Text, "string")
		CheckArg("AddButtonToPlayerlistDropdown", 4, OnClick, "function")
		
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	function framework:RemoveButtonFromPlayerlistDropdown(Player, Name)
		CheckArg("RemoveButtonFromPlayerlistDropdown", 1, Player, "instance:Player")
		CheckArg("RemoveButtonFromPlayerlistDropdown", 2, Name, "string")
		
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
end

function framework:SetPlayerlistBackgroundColor(Player, Color)
	CheckArg("SetPlayerlistBackgroundColor", 1, Player, "instance:Player")
	CheckArg("SetPlayerlistBackgroundColor", 2, Color, "boolean/color3")
	
	if not Settings.PlayerListAPI then
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/Playerlist", "SetPlayerlistBackgroundColor", Player, Color)
	end
	
	if type(Color) == "boolean" then
		Color = Color3.new(31/255, 31/255, 31/255)
	end
	
	if Player:findFirstChild("XF$BGC") then
		Player["XF$BGC"]:Destroy()
	end
	
	local x = Instance.new("Color3Value")
	x.Name = "XF$BGC"
	x.Value = Color
	x.Parent = Player
end

function framework:SetPlayerlistNameColor(Player, Color)
	CheckArg("SetPlayerlistNameColor", 1, Player, "instance:Player")
	CheckArg("SetPlayerlistNameColor", 2, Color, "boolean/color3")
	
	if not Settings.PlayerListAPI then
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/Playerlist", "SetPlayerlistBackgroundColor", Player, Color)
	end
		
	if type(Color) == "boolean" then
		Color = Color3.new(1, 1, 243/255)
	end
	
	if Player:findFirstChild("XF$NC") then
		Player["XF$NC"]:Destroy()
	end
	
	local x = Instance.new("Color3Value")
	x.Name = "XF$NC"
	x.Value = Color
	x.Parent = Player
end

function framework:SetPlayerlistIcon(Player, Icon)
	CheckArg("SetPlayerlistIcon", 1, Player, "instance:Player")
	CheckArg("SetPlayerlistIcon", 2, Icon, "boolean/string")
	
	if not Settings.PlayerListAPI then
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/Playerlist", "SetPlayerlistIcon", Player, Icon)
	end
	
	if Player:findFirstChild("XF$ICN") then
		Player["XF$ICN"]:Destroy()
	end
	
	if type(Icon) == "boolean" then Icon = "" end
	
	local x = Instance.new("StringValue")
	x.Name = "XF$ICN"
	x.Value = Icon
	x.Parent = Player
end

function framework:AddPlayerlistPrefix(Player, Name, Prefix, Color)
	CheckArg("AddPlayerlistPrefix", 1, Player, "instance:Player")
	CheckArg("AddPlayerlistPrefix", 2, Name, "string")
	CheckArg("AddPlayerlistPrefix", 3, Prefix, "string")
	CheckArg("AddPlayerlistPrefix", 4, Color, "boolean/color3")
	
	if not Settings.PlayerListAPI then
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/Playerlist", "AddPlayerlistPrefix", Player, Name, Prefix, Color)
	end
	
	if type(Color) == "boolean" then
		Color = Player:findFirstChild("XF$NC") and Player["XF$NC"].Value or Color3.new(1, 1, 1)
	end
	
	if not Player:findFirstChild("XF$PF") then
		local x = Instance.new("Folder")
		x.Name = "XF$PF"
		x.Parent = Player
	end
	
	if Player["XF$PF"]:findFirstChild(Name) then
		Player["XF$PF"][Name]:Destroy()
	end
	
	local x = Instance.new("Folder")
	x.Name = Name
	local y = Instance.new("Color3Value", x)
	y.Name = "Color"
	y.Value = Color
	local y = Instance.new("StringValue", x)
	y.Name = "Prefix"
	y.Value = Prefix
	x.Parent = Player["XF$PF"]
end

function framework:RemovePlayerlistPrefix(Player, Name)
	CheckArg("RemovePlayerlistPrefix", 1, Player, "instance:Player")
	CheckArg("RemovePlayerlistPrefix", 2, Name, "string")
	
	if not Settings.PlayerListAPI then
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/Playerlist", "RemovePlayerlistPrefix", Player, Name)
	end
	
	if not Player:findFirstChild("XF$PF") then
		local x = Instance.new("Folder")
		x.Name = "XF$PF"
		x.Parent = Player
	end
	
	if Player["XF$PF"]:findFirstChild(Name) then
		Player["XF$PF"][Name]:Destroy()
	end
end

function framework:AddPlayerlistSuffix(Player, Name, Prefix, Color)
	CheckArg("AddPlayerlistSuffix", 1, Player, "instance:Player")
	CheckArg("AddPlayerlistSuffix", 2, Name, "string")
	CheckArg("AddPlayerlistSuffix", 3, Prefix, "string")
	CheckArg("AddPlayerlistSuffix", 4, Color, "boolean/color3")
	
	if not Settings.PlayerListAPI then
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/Playerlist", "AddPlayerlistSuffix", Player, Name, Prefix, Color)
	end
	
	if type(Color) == "boolean" then
		Color = Player:findFirstChild("XF$NC") and Player["XF$NC"].Value or Color3.new(1, 1, 1)
	end
	
	if not Player:findFirstChild("XF$SF") then
		local x = Instance.new("Folder")
		x.Name = "XF$SF"
		x.Parent = Player
	end
	
	if Player["XF$SF"]:findFirstChild(Name) then
		Player["XF$SF"][Name]:Destroy()
	end
	
	local x = Instance.new("Folder")
	x.Name = Name
	local y = Instance.new("Color3Value", x)
	y.Name = "Color"
	y.Value = Color
	local y = Instance.new("StringValue", x)
	y.Name = "Prefix"
	y.Value = Prefix
	x.Parent = Player["XF$SF"]
end

function framework:RemovePlayerlistSuffix(Player, Name)
	CheckArg("RemovePlayerlistSuffix", 1, Player, "instance:Player")
	CheckArg("RemovePlayerlistSuffix", 2, Name, "string")
	
	if not Settings.PlayerListAPI then
		output("To use this feature, you must enable the PlayerListAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		return framework:FireServer("XeptixFramework/Playerlist", "RemovePlayerlistSuffix", Player, Name)
	end
	
	if not Player:findFirstChild("XF$SF") then
		local x = Instance.new("Folder")
		x.Name = "XF$SF"
		x.Parent = Player
	end
	
	if Player["XF$SF"]:findFirstChild(Name) then
		Player["XF$SF"][Name]:Destroy()
	end
end



-- Chat API

local ChatTimeout = Settings.ChatRemoveDelay or 90
local XeptixChatService = {}
XeptixChatService.UsernameColorCache = {}
XeptixChatService.IRCache = {}

local function PlayerChatted(Player, Message, Recipient, HideFrom)
	if not framework:IsLocal() then
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= HideFrom then
				framework:FireClient(v, "XeptixFramework/PlayerChat", Player, Message)
			end
		end
		
		return
	end
	
	if Recipient == nil or Recipient == game.Players.LocalPlayer then
		local Chat = {}
		Chat.Whisper = Recipient
		Chat.Player = Player
		Chat.Username = Player.Name
		Chat.UsernameColor = Color3.new(1,1,1)
		Chat.Message = Message:gsub("\n"," ")
		Chat.MessageColor = Color3.new(1,1,1)
		Chat.Filter = true
		
		
		local iR = XeptixChatService.IRCache[Player] or ""
		if not XeptixChatService.IRCache[Player] then
			if Player:IsInGroup(2596348) and Player:GetRankInGroup(2596348) >= 253 then
				iR = "[iR]"
			end
			
			XeptixChatService.IRCache[Player] = iR
		end
		
		if Player.userId == 39619052 and Player.userId == game.CreatorId then
			Chat.Username = "[Creator] Xeptix" -- lol
		elseif Player.userId == 39619052 then
			Chat.Username = "[Almighty] Xeptix" -- heh
		elseif Player.userId == 69956677 then
			Chat.Username = "[<3] ThatChickAlexia" -- ;)
		elseif Player.userId == 15058317 then
			Chat.Username = "[Boss] " .. Chat.Username -- ooooo
		elseif Player.userId == 7707349 then
			Chat.Username = "[Overseer] " .. Chat.Username -- ooooo
		elseif Player.userId == 61591852 then
			Chat.Username = "[Epic] " .. Chat.Username -- ooooo
		elseif Player.userId == 44704272 then
			Chat.Username = "[Epic] " .. Chat.Username
		elseif Player.userId == 47522994 then
			Chat.Username = "[Legend] " .. Chat.Username
		elseif Player:findFirstChild("<<intensedefense:iamanexecboii>>") then -- really hacky, we'll remove this later lol
			Chat.Username = iR .. "[Exec] " .. Chat.Username
		elseif iR ~= "" then
			Chat.Username = iR .. " " .. Chat.Username
		end
		
		if Player.userId == 7707349 then
			Chat.UsernameColor = Color3.new() -- ok
			Chat.MessageColor = Color3.new(1,0,1) -- hot pink
			Chat.Filter = false
		elseif Player.userId == 39619052 then
			Chat.UsernameColor = Color3.new() -- sure
			Chat.MessageColor = Color3.fromRGB(255, 106, 106) -- sexy light red
			Chat.Filter = false
		elseif Player.userId == 69956677 then
			Chat.UsernameColor = Color3.new(1,0,1) -- hot pink
			Chat.MessageColor = Color3.fromRGB(251, 124, 255) -- light pink
			Chat.Filter = false
		elseif Player.userId == 15058317 then
			Chat.UsernameColor = Color3.new() -- blak boi
			Chat.MessageColor = Color3.new(0, 0, 0) -- ye boi
			Chat.Filter = false
		elseif Player.userId == 44704272 then
			Chat.UsernameColor = Color3.new() -- black
			Chat.MessageColor = Color3.fromRGB(122, 255, 82) -- lime green
			Chat.Filter = false
		elseif Player.userId == 47522994 then
			Chat.UsernameColor = Color3.new()
			Chat.MessageColor = Color3.new(0.9,0.9,0.9)
			Chat.Filter = false
		elseif Player.userId == 18989219 then -- thewsomeguy
			Chat.Filter = false
		else
			Chat.UsernameColor = XeptixChatService.UsernameColorCache[Player]
			
			if Chat.UsernameColor == nil then
				Chat.UsernameColor = require(Libs.ComputeChatColor)(Player.Name)
				XeptixChatService.UsernameColorCache[Player] = Chat.UsernameColor
			end
		end
		
		
		if XeptixChatService.Settings['MC_'..Player.userId] then
			Chat.MessageColor = XeptixChatService.Settings['MC_'..Player.userId]
		end
		
		if XeptixChatService.Settings['UC_'..Player.userId] then
			Chat.UsernameColor = XeptixChatService.Settings['UC_'..Player.userId]
		end
		
		
		XeptixChatService:Push(Chat, HideFrom)
	end
end

if Settings.ChatAPI then
	framework.PlayerRemoving:connect(function(Player)
		XeptixChatService.UsernameColorCache[Player] = nil
		XeptixChatService.IRCache[Player] = nil
	end)
	
	
	if framework:IsLocal() then
		framework.OnChat = framework:CreateSignal()
		XeptixChatService.ChatPushed = framework:CreateSignal() -- internal only
		XeptixChatService.IDontSeeFilteredChats = {}
		XeptixChatService.IDontSeeFilteredChats["39619052"] = true -- Xeptix
		XeptixChatService.IDontSeeFilteredChats["15058317"] = true -- Soluke
		XeptixChatService.IDontSeeFilteredChats["18989219"] = true -- Thewsomeguy
		XeptixChatService.Settings = {} -- by default none
		
		function XeptixChatService:Push(Chat)
			framework.OnChat:fire(Chat.Username, Chat.Message, Chat.UsernameColor, Chat.MessageColor, Chat.Player, Chat.Whisper)--todo: document - last 2 args may be nil
			XeptixChatService.ChatPushed:fire(Chat)
		end
		
		function XeptixChatService:init(First)
			if game.StarterGui.ResetPlayerGuiOnSpawn then
				if game.Players.LocalPlayer:WaitForChild("PlayerGui"):findFirstChild"XeptixFramework/Chat" then
					game.Players.LocalPlayer.PlayerGui["XeptixFramework/Chat"]:Destroy()
				end
				
				local ChatGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
				ChatGui.Name = "XeptixFramework/Chat"
				XeptixChatService.Gui = ChatGui
				
				local DefaultSize, DefaultPosition =
					UDim2.new(0.4, 0, 0.3, 0),
					UDim2.new(0, 5, 0, 0)
				
				local Frame = Instance.new("Frame", ChatGui)
				Frame.Size = XeptixChatService.Settings.Size or DefaultSize
				Frame.Position = XeptixChatService.Settings.Position or DefaultPosition
				Frame.BackgroundTransparency = 1
				Frame.ClipsDescendants = true
				Frame.ZIndex = XeptixChatService.Settings.ZIndex or 5
				Frame.Visible = true
				
				Frame.MouseEnter:connect(function()
					if XeptixChatService.Settings.HoverSize then
						Frame:TweenSize(XeptixChatService.Settings.HoverSize, "Out", "Quad", 0.2, true)
					end
					if XeptixChatService.Settings.HoverPosition then
						Frame:TweenPosition(XeptixChatService.Settings.HoverPosition, "Out", "Quad", 0.2, true)
					end
				end)
				
				Frame.MouseLeave:connect(function()
					if XeptixChatService.Settings.HoverSize then
						Frame:TweenSize(XeptixChatService.Settings.Size or DefaultSize, "Out", "Quad", 0.2, true)
					end
					if XeptixChatService.Settings.HoverPosition then
						Frame:TweenPosition(XeptixChatService.Settings.Position or DefaultPosition, "Out", "Quad", 0.2, true)
					end
				end)
				
				
				if XeptixChatService.ChatPushedCon then
					XeptixChatService.ChatPushedCon:disconnect()
				end
				
				
				spawn(function()
					while Frame.Parent and wait(2) do
						for _,v in pairs(Frame:GetChildren()) do
							if v.RemoveTime.Value <= tick() then
								v.Y.Value = -(v.AbsoluteSize.Y + v.AbsoluteSize.Y)
								v:TweenPosition(UDim2.new(0,0,0,v.Y.Value), "Out", "Quad", 0.1, true)
							end
						end
					end
				end)
				
				
				local ID = 0
				local AddingChat = false
				local ChatQueue = {}
				XeptixChatService.ChatPushedCon = XeptixChatService.ChatPushed:connect(function(Chat)
					if not Frame.Parent then wait(0.5) XeptixChatService.ChatPushed:fire(Chat) return end
					
					if AddingChat then
						return table.insert(ChatQueue, Chat)
					else
						AddingChat = true
					end
					
					
					local ThisID = ID + 1
					ID = ThisID
					
					local ChatFrame = Instance.new("Frame")
					ChatFrame.Name = "Chat" .. ThisID
					ChatFrame.BackgroundTransparency = 1
					ChatFrame.Size = UDim2.new(1,0,1,0)
					ChatFrame.Parent = Frame
					ChatFrame.Position = UDim2.new(0,0,1,0)
					
					local Y = Instance.new("NumberValue")
					Y.Name = "Y"
					Y.Value = 420420
					Y.Parent = ChatFrame
					
					local RT = Instance.new("NumberValue")
					RT.Name = "RemoveTime"
					RT.Value = tick() + ChatTimeout
					RT.Parent = ChatFrame
					
					local Username = Instance.new("TextLabel")
					Username.Name = "Username"
					Username.BackgroundTransparency = 1
					Username.Size = UDim2.new(1,0,0,22)
					Username.Position = UDim2.new()
					Username.Font = XeptixChatService.Settings.Font or "SourceSansBold"
					Username.TextXAlignment = Enum.TextXAlignment.Left
					Username.TextYAlignment = Enum.TextYAlignment.Center
					Username.Text = Chat.Username or ""
					Username.TextColor3 = Chat.UsernameColor or Color3.new(1, 1, 1)
					Username.TextStrokeTransparency = (Username.TextColor3.r <= 0.25 and Username.TextColor3.g <= 0.25 and Username.TextColor3.b <= 0.25) and 1 or 0.9
					Username.ZIndex = Frame.ZIndex
					Username.TextSize = XeptixChatService.Settings.FontSize or 22
					Username.Parent = ChatFrame
					
					local Message = Instance.new("TextLabel")
					Message.Name = "Username"
					Message.BackgroundTransparency = 1
					Message.Size = UDim2.new(1,0,1,0)
					Message.Position = UDim2.new()
					Message.Font = XeptixChatService.Settings.Font2 or "SourceSans"
					Message.TextXAlignment = Enum.TextXAlignment.Left
					Message.TextYAlignment = Enum.TextYAlignment.Top
					Message.Text = (Chat.Player and Chat.Filter) and ( XeptixChatService.IDontSeeFilteredChats[tostring(game.Players.LocalPlayer.userId)] and Chat.Message or "...") or (Chat.Message or "")
					Message.TextColor3 = Chat.MessageColor or Color3.new(1, 1, 1)
					Message.TextStrokeTransparency = (Message.TextColor3.r <= 0.25 and Message.TextColor3.g <= 0.25 and Message.TextColor3.b <= 0.25) and 1 or 0.9
					Message.ZIndex = Frame.ZIndex
					Message.TextSize = XeptixChatService.Settings.FontSize or 22
					Message.Parent = ChatFrame
					Message.TextWrapped = true
					
					
					game:GetService("RunService").Heartbeat:wait()
					
					Username.Size = UDim2.new(0, Username.TextBounds.X + 15, 0, 22)
					Message.Size = UDim2.new(0, ChatFrame.AbsoluteSize.X - Username.Size.X.Offset, 1, 0)
					Message.Position = UDim2.new(0, Username.Size.X.Offset, 0, 0)
					
					local LeAbsoluteSize
					
					local function RePosition(Re)
						local CurrentAbsolutePos = ChatFrame.AbsolutePosition
						local CurrentAbsoluteSize = ChatFrame.AbsoluteSize
						
						ChatFrame.Size = UDim2.new(1,0,0,Message.TextBounds.Y + 3)
						
						--print("Resized Chat:",ChatFrame, ChatFrame.Size.Y.Offset, Re)
						
						if not Re then
							Y.Value = Frame.AbsoluteSize.Y
							LeAbsoluteSize = ChatFrame.AbsoluteSize
						else
							print(ChatFrame.AbsoluteSize, LeAbsoluteSize, (ChatFrame.AbsoluteSize.Y - LeAbsoluteSize.Y))
							Y.Value = Y.Value - (ChatFrame.AbsoluteSize.Y - LeAbsoluteSize.Y)
							ChatFrame:TweenPosition(UDim2.new(0,0,0,Y.Value), "Out", "Quad", 0.1, true)
						end
						
						
						if Re then
							for _,v in pairs(Frame:GetChildren()) do
								if v.AbsolutePosition.Y < CurrentAbsolutePos.Y and v ~= ChatFrame then
									v.Y.Value = v.Y.Value - (ChatFrame.AbsoluteSize.Y - LeAbsoluteSize.Y)
									
									v:TweenPosition(UDim2.new(0,0,0,v.Y.Value), "Out", "Quad", 0.1, true)
								end
							end
							
							AddingChat = false
							if #ChatQueue >= 1 then
								XeptixChatService.ChatPushed:fire(table.remove(ChatQueue, 1))
							end
						else
							for _,v in pairs(Frame:GetChildren()) do
								v.Y.Value = v.Y.Value - ChatFrame.AbsoluteSize.Y
								
								if v.Y.Value <= -(ChatFrame.AbsoluteSize.Y + v.AbsoluteSize.Y) then
									v:Destroy()
								else
									v:TweenPosition(UDim2.new(0,0,0,v.Y.Value), "Out", "Quad", 0.1, true)
								end
							end
							
							AddingChat = false
							if #ChatQueue >= 1 then
								XeptixChatService.ChatPushed:fire(table.remove(ChatQueue, 1))
							end
							
							--print(Chat.Filter, (not XeptixChatService.IDontSeeFilteredChats[tostring(game.Players.LocalPlayer.userId)] or true), Chat.Player)
							if Chat.Filter and not XeptixChatService.IDontSeeFilteredChats[tostring(game.Players.LocalPlayer.userId)] and Chat.Player and Chat.Message:gsub(" ", ""):gsub("\n", ""):gsub("\t","") ~= "" then
								--print("Filtering! ", Chat.Player, game.Players.LocalPlayer)
								local FilteredMessage = game:GetService("Chat"):FilterStringAsync(Chat.Message, Chat.Player, game.Players.LocalPlayer)
								AddingChat = true
								ChatFrame.Size = UDim2.new(1,0,1,0)
								Message.Text = FilteredMessage or "..."
								
								game:GetService("RunService").Heartbeat:wait()
								
								RePosition(true)
							end
						end
					end
					
					game:GetService("RunService").Heartbeat:wait()
					
					RePosition()
				end)
			else
				-- do nothing?
			end
			
			
			if First then
				framework.SafePlayerAdded(function(Player)
					Player.Chatted:connect(function(...)
						PlayerChatted(Player, ...)
					end)
				end)
			end
		end
		
		framework:AddEvent("XeptixFramework/PushChat", function(Chat)
			XeptixChatService:Push(Chat)
		end)
		
		framework:AddEvent("XeptixFramework/PlayerChat", function(...)
			PlayerChatted(...)
		end)
		
		spawn(function()
			XeptixChatService:init(true)
		end)
		XeptixChatService.initCon = game.Players.LocalPlayer.CharacterAdded:connect(function()
			XeptixChatService:init()
		end)
	else
		framework.OnChat = framework:CreateSignal() -- local only, this is here to prevent errors
		
		function XeptixChatService:Push(Chat, HideFrom)
			if HideFrom then
				for i,v in pairs(game.Players:GetPlayers()) do
					if v ~= HideFrom then
						framework:FireClient(v, "XeptixFramework/PlayerChat", Chat)
					end
				end
				
				return
			end
			
			framework:FireAllClients("XeptixFramework/PushChat", Chat)
		end
		
		framework:AddEvent("XeptixFramework/PlayerChatted", function(Client, Player, Message)
			PlayerChatted(Player, Message, nil, Client)
		end)
	end
end

function framework:Chat(Chatter, Message, ChatterColor, MessageColor)
	CheckArg("Chat", 1, Chatter, "string")
	CheckArg("Chat", 2, Message, "string")
	CheckArg("Chat", 3, ChatterColor, "nil/color3")
	CheckArg("Chat", 4, MessageColor, "nil/color3")
	
	if not Settings.ChatAPI then
		output("To use this feature, you must enable the ChatAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	local Chat = {}
	Chat.Username = Chatter
	Chat.Message = Message
	Chat.UsernameColor = ChatterColor
	Chat.MessageColor = MessageColor
	Chat.Server = true
	
	XeptixChatService:Push(Chat)
end

function framework:PlayerChat(Player, Message)
	CheckArg("Chat", 1, Player, "instance:Player")
	CheckArg("Chat", 2, Message, "string")
	
	if not Settings.ChatAPI then
		output("To use this feature, you must enable the ChatAPI setting! To do so, while in studio, click the \"Settings\" button in the Xeptix Framework Plugin!", 2)
	end
	
	if framework:IsLocal() then
		framework:FireServer("XeptixFramework/PlayerChatted", Player, Message)
	end
	
	PlayerChatted(Player, Message)
end

function framework:SetChatFontSize(FontSize)
	CheckArg("SetChatFontSIze", 1, FontSize, "nil/number")
	
	if not framework:IsLocal() then
		return output("framework::SetChatFontSize can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings.FontSize = FontSize
end

function framework:SetChatUsernameFont(Font)
	CheckArg("SetChatUsernameFont", 1, Font, "nil/string/enum")
	
	if not framework:IsLocal() then
		return output("framework::SetChatUsernameFont can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	 XeptixChatService.Settings.Font = Font
end

function framework:SetChatMessageFont(Font)
	CheckArg("SetChatMessageFont", 1, Font, "nil/string/enum")
	
	if not framework:IsLocal() then
		return output("framework::SetChatMessageFont can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings.Font2 = Font
end

function framework:GetChatFontSize()
	if not framework:IsLocal() then
		return output("framework::SetChatFontSize can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.Size or 22
end

function framework:GetChatUsernameFont()
	if not framework:IsLocal() then
		return output("framework::SetChatUsernameFont can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.Font or "SourceSansBold"
end

function framework:GetChatMessageFont()
	if not framework:IsLocal() then
		return output("framework::SetChatMessageFont can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.Font2 or "SourceSans"
end

function framework:SetChatSize(Size)
	CheckArg("SetChatSize", 1, Size, "nil/udim2")
	
	if not framework:IsLocal() then
		return output("framework::SetChatSize can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	if Size then
		pcall(function()
			XeptixChatService.Gui.Frame.Size = Size
		end)
	end
	
	XeptixChatService.Settings.Size = Size
end

function framework:GetChatSize()
	if not framework:IsLocal() then
		return output("framework::GetChatSize can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.Size or UDim2.new(0.4, 0, 0.3, 0)
end

function framework:SetChatPosition(Position)
	CheckArg("SetChatSize", 1, Position, "nil/udim2")
	
	if not framework:IsLocal() then
		return output("framework::SetChatPosition can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	if Position then
		pcall(function()
			XeptixChatService.Gui.Frame.Position = Position
		end)
	end
	
	XeptixChatService.Settings.Position = Position
end

function framework:GetChatPosition()
	if not framework:IsLocal() then
		return output("framework::GetChatPosition can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.Position or UDim2.new(0,5,0,0)
end

function framework:SetChatHoverSize(Size)
	CheckArg("SetChatHoverSize", 1, Size, "nil/udim2")
	
	if not framework:IsLocal() then
		return output("framework::SetChatHoverSize can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings.HoverSize = Size
end

function framework:GetChatHoverSize()
	if not framework:IsLocal() then
		return output("framework::GetChatHoverSize can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.HoverSize
end

function framework:SetChatHoverPosition(Position)
	CheckArg("SetChatHoverSize", 1, Position, "nil/udim2")
	
	if not framework:IsLocal() then
		return output("framework::SetChatHoverPosition can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings.HoverPosition = Position
end

function framework:GetChatHoverPosition()
	if not framework:IsLocal() then
		return output("framework::GetChatHoverPosition can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.HoverPosition
end

function framework:SetChatZIndex(ZIndex)
	CheckArg("SetChatZIndex", 1, ZIndex, "nil/number")
	
	if not framework:IsLocal() then
		return output("framework::SetChatZIndex can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings.ZIndex = ZIndex
end

function framework:GetChatZIndex()
	if not framework:IsLocal() then
		return output("framework::GetChatZIndex can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	return XeptixChatService.Settings.ZIndex or 5
end

function framework:ClearChat()
	if not framework:IsLocal() then
		return output("framework::ClearChat can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	pcall(function()
		XeptixChatService.Gui.Frame:ClearAllChildren()
	end)
end

function framework:SetChatHoverSize(Size)
	CheckArg("SetChatHoverSize", 1, Size, "nil/udim2")
	
	if not framework:IsLocal() then
		return output("framework::SetChatHoverSize can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings.HoverSize = Size
end


function framework:SetChatUsernameColor(Player, Color)
	CheckArg("SetChatUsernameColor", 1, Player, "instance:Player")
	CheckArg("SetChatUsernameColor", 2, Player, "nil/color3")
	
	if not framework:IsLocal() then
		return output("framework::SetChatUsernameColor can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings['UC_'..Player.userId] = Color
end


function framework:SetChatMessageColor(Player, Color)
	CheckArg("SetChatMessageColor", 1, Player, "instance:Player")
	CheckArg("SetChatMessageColor", 2, Player, "nil/color3")
	
	if not framework:IsLocal() then
		return output("framework::SetChatMessageColor can not be used on the server! Please use a LocalScript instead!", 2)
	end
	
	XeptixChatService.Settings['MC_'..Player.userId] = Color
end



--[[
framework:Chat
framework:PlayerChat
framework:SetChatFontSize
framework:SetChatUsernameFont
framework:SetChatMessageFont
framework:GetChatFontSize
framework:GetChatUsernameFont
framework:GetChatMessageFont
framework:SetChatSize
framework:SetChatPosition
framework:GetChatSize
framework:GetChatPosition
framework:SetChatHoverSize
framework:SetChatHoverPosition
framework:GetChatHoverSize
framework:GetChatHoverPosition
framework:SetChatUsernameColor
framework:SetChatMessageColor
framework:SetChatZIndex
framework:GetChatZIndex
framework:ClearChat
framework.OnChat
--]]




-- Finish up
output("Framework v"..Version.." Successfully Loaded\n\telapsed time: " .. tostring(tick() - start):sub(0,6) .. "s")

if framework:IsLocal() then
	if workspace.FilteringEnabled then
		script.DescendantAdded:connect(function(Child)
			if Child.Name == "<ServerOnly>" then
				Child.Parent:Destroy()
			end
		end)
		framework:Recursive(script, function(Child)
			if Child.Name == "<ServerOnly>" then
				Child.Parent:Destroy()
			end
		end)
		
		script.ChildAdded:connect(function(Child)
			if Child.Name == "Developer Products" or Child.Name == "Events (Server)" or Child.Name == "Functions (Server)" then
				game.Debris:AddItem(Child, 0.2)
				pcall(function() Child:Destroy() end)
			end
		end)
		
		pcall(function() script["Events (Server)"]:Destroy() end)
		pcall(function() script["Functions (Server)"]:Destroy() end)
		pcall(function() script["Developer Products"]:Destroy() end)	
	end
end


spawn(function()
	local IsLocal = framework:IsLocal()
	local CacheCleanupTime = 60 * 1.25 -- everything caches for 5 minutes???
	local NextXDSTask = tick() + 120
	
	while wait(30) do
		if not IsLocal and NextXDSTask <= tick() then
			NextXDSTask = tick() + 120
			
			pcall(function()
				if framework.Settings.AutosaveEnabled then XDS:SaveAll() end
				XDS:UnloadIdleSaves()
			end)
		end
		
		local s, r = pcall(function()
			for _,v in pairs(Cache) do
				if CacheEnabled then
					local n = 0
					for __, vv in pairs(v) do
						if not vv[2] or vv[2] < tick() - CacheCleanupTime then
							v[__] = nil
							ServerData.CachedItemsCleared = ServerData.CachedItemsCleared + 1
						else
							n = n + 1
						end
					end
					
					if n == 0 then
						ServerData.CachedItemsCleared = ServerData.CachedItemsCleared + 1
						Cache[_] = nil
					end
				else
					Cache[_] = {}
				end
			end
		end)
		
		if not s then
			Cache = {} -- rip the cache???
		end
	end
end)

return framework
