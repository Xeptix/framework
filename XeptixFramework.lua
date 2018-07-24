-- Xeptix Framework 3.1 (build 508; debug disabled; framework prints disabled)
-- Documentation: https://github.com/xeptix/framework/wiki
-- Website: https://framework.xeptix.com
-- This framework is designed to help you out with development by adding many awesome services, and allowing you to create
-- your own custom properties, methods, and events for all objects. These work cross-script, but server/client do not share
-- these even if you're not using Filtering Enabled.
-- Supports all games, both group and personal, with all settings (including fe/non-fe).


-- Do not edit this script, as when the framework updates your changes will be erased.
---> Do feel free to create your own services and jobs, but only do so if you are an advanced scripter. <---
-- Making a backup is not a bad idea.



-- Check out our github to view documentation, add to the framework, or fix bugs yourself! https://github.com/xeptix/framework
-- Always be sure to read documentation if it is your first time using a feature - all information you need is displayed there!









FrameworkModule = game:findFirstChild(".xeptixframework.", true).Parent
Original = {["tostring"] = tostring, ["require"] = require, ["print"] = print, ["Instance"] = Instance, ["typeof"] = typeof, ["type"] = type, ["game"] = game, ["Game"] = game, ["Workspace"] = workspace, ["workspace"] = workspace, ["math"] = math, ["table"] = table, ["string"] = string}
FrameworkServices = {}
FrameworkJobs = {}
superLockedProperties = {}
superLockedProperties.____o = true
superLockedProperties.____s = true
superLockedProperties.____l = true
superLockedProperties.____c = true
superLockedProperties.____e = true
superLockedProperties.LockProperty = true
superLockedProperties.SetProperty = true
superLockedProperties.SetMethod = true
superLockedProperties.SetEvent = true
superLockedProperties.HasProperty = true
superLockedProperties.CanReadProperty = true
superLockedProperties.CanWriteProperty = true
APIDump = game.HttpService:JSONDecode(require(FrameworkModule[".xeptixframework."].APIDump))
RbxUtility = LoadLibrary("RbxUtility")
ModifiedObjects = {
	["root"] = {
		IsA = function(self, ClassName)
			game.FrameworkService:CheckArgument(debug.traceback(), "IsA", 1, ClassName, "string")

			if ClassName == "XeptixFrameworkService" and self:HasProperty("XeptixFrameworkService") then
				return true
			elseif ClassName == "XeptixObject" then
				return true
			elseif rawget(self, "ClassName") == ClassName then
				return true
			elseif rawget(self, "SuperClassName") == ClassName then
				return true
			elseif ClassName == "root" then
				return true
			else
				return rawget(self, "____o"):IsA(ClassName)
			end
		end,
		FindFirstChild = function(self, ClassName, Recursive)
			game.FrameworkService:CheckArgument(debug.traceback(), "FindFirstChildOfClass", 1, ClassName, "string")
			game.FrameworkService:CheckArgument(debug.traceback(), "FindFirstChildOfClass", 2, Recursive, {"boolean", "nil"})

			local O = rawget(self, "____o"):FindFirstChild(ClassName, Recursive)
			if O then
				O = Object(O)
			end

			return O
		end,
		findFirstChild = function(self, ...)
			return rawget(self, "FindFirstChild")(self, ...)
		end,
		FindFirstChildOfClass = function(self, ClassName, Recursive)
			game.FrameworkService:CheckArgument(debug.traceback(), "FindFirstChildOfClass", 1, ClassName, "string")
			game.FrameworkService:CheckArgument(debug.traceback(), "FindFirstChildOfClass", 2, Recursive, {"boolean", "nil"})

			local O = rawget(self, "____o"):FindFirstChildOfClass(ClassName)
			if O then
				O = Object(O)
			else
				return self:FindFirstChildWithProperty("ClassName", ClassName, Recursive)
			end

			return O
		end,
		findFirstChildOfClass = function(self, ...)
			return rawget(self, "FindFirstChildOfClass")(self, ...)
		end,--
		FindFirstChildWithProperty = function(self, Name, Value, Recursive)
			game.FrameworkService:CheckArgument(debug.traceback(), "FindFirstChildOfClass", 1, Name, "string")
			game.FrameworkService:CheckArgument(debug.traceback(), "FindFirstChildOfClass", 3, Recursive, {"boolean", "nil"})

			if Recursive then
				local Obj
				Object:Recursive(function(v)
					if v:CanReadProperty(Name) and (Value == nil or v[Name] == Value) then
						Obj = v
						return
					end
				end)

				return Obj
			else
				for _,v in pairs(self:GetChildren()) do
					if v:CanReadProperty(Name) and (Value == nil or v[Name] == Value) then
						return v
					end
				end
			end
		end,
		findFirstChildWithProperty = function(self, ...)
			return rawget(self, "FindFirstChildWithProperty")(self, ...)
		end,
		WaitForChild = function(self, Name, Timeout, Recursive)
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChild", 1, Name, "string")
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChild", 2, Timeout, {"number", "nil"})
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChild", 3, Recursive, {"boolean", "nil"})

			if Recursive then
				local Obj
				local Stop = os.time() + (Timeout or 999999)
				while not Obj and Stop >= os.time() do
					Obj = self:FindFirstChild(Name, true)

					if not Obj then wait() end
				end

				return Obj
			end

			local O = rawget(self, "____o"):WaitForChild(Name, Timeout)
			if O then
				O = Object(O)
			end

			return O
		end,
		waitForChild = function(self, ...)
			return rawget(self, "WaitForChild")(self, ...)
		end,
		WaitForChildOfClass = function(self, Name, Timeout, Recursive)
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChildOfClass", 1, Name, "string")
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChildOfClass", 2, Timeout, {"number", "nil"})
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChildOfClass", 3, Recursive, {"boolean", "nil"})

			local Obj
			local Stop = os.time() + (Timeout or 999999)
			while not Obj and Stop >= os.time() do
				Obj = self:FindFirstChildOfClass(Name, Recursive)

				if not Obj then wait() end
			end

			return Obj
		end,
		waitForChildOfClass = function(self, ...)
			return rawget(self, "WaitForChildOfClass")(self, ...)
		end,
		WaitForChildWithProperty = function(self, Name, Value, Timeout, Recursive)
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChildWithProperty", 1, Name, "string")
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChildWithProperty", 3, Timeout, {"number", "nil"})
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForChildWithProperty", 4, Recursive, {"boolean", "nil"})

			local Obj
			local Stop = os.time() + (Timeout or 999999)
			while not Obj and Stop >= os.time() do
				Obj = self:FindFirstChildWithProperty(Name, Value, Recursive)

				if not Obj then wait() end
			end

			return Obj
		end,
		waitForChildWithProperty = function(self, ...)--
			return rawget(self, "WaitForChildWithProperty")(self, ...)
		end,
		GetRandomChild = function(self)
			local Children = self:GetChildren()

			if #Children > 0 then
				return Children[math.random(#Children)]
			end
		end,
		Recursive = function(self, callback)
			game.FrameworkService:CheckArgument(debug.traceback(), "Recursive", 1, callback, "function")

			local function search(parent)
				local nextLoop = {}
				for _,v in pairs(parent:GetChildren()) do
					if #v:GetChildren() > 0 then
						table.insert(nextLoop, v)
					end

					callback(v)
				end

				for _,v in pairs(nextLoop) do
					search(v)
				end
			end

			search(self)
		end,
		CanReadProperty = function(self, name)
			game.FrameworkService:CheckArgument(debug.traceback(), "CanReadProperty", 1, name, "string")

			if rawget(self, "____l")[name .. "____l1"] or rawget(self, "____l")[name .. "____l3"] then
				return false
			end

			local can = false
			pcall(function()
				local x = self[name]
				can = true
			end)

			return can
		end,
		CanModifyProperty = function(self, name)
			game.FrameworkService:CheckArgument(debug.traceback(), "CanModifyProperty", 1, name, "string")

			local can = true
			if rawget(self, "____l")[name .. "____l2"] or rawget(self, "____l")[name .. "____l3"] then
				can = false
			end

			return can
		end,
		HasProperty = function(self, name)
			game.FrameworkService:CheckArgument(debug.traceback(), "HasProperty", 1, name, "string")

			return (rawget(self, name) or rawget(self, "____l")[name .. "____l2"] or pcall(function() local x = rawget(self, "____o")[name] end)) and true or false
		end,
		HasMethod = function(self, name)
			game.FrameworkService:CheckArgument(debug.traceback(), "HasMethod", 1, name, "string")

			local x
			local y = (rawget(self, name) or rawget(self, "____l")[name .. "____l2"] or pcall(function() x = rawget(self, "____o")[name] end)) and true or false
			if x or y then
				return typeof(x) == "function" or typeof(y) == "function"
			end
		end,
		HasEvent = function(self, name)
			game.FrameworkService:CheckArgument(debug.traceback(), "HasEvent", 1, name, "string")

			local x
			local y = (rawget(self, name) or rawget(self, "____l")[name .. "____l2"] or pcall(function() x = rawget(self, "____o")[name] end)) and true or false
			if x or y then
				return typeof(x) == "RBXScriptSignal" or typeof(y) == "RBXScriptSignal"
			end
		end,
		SetProperty = function(self, property, value)
			if superLockedProperties[property] then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Property '" .. property .. "' of game" .. ((fn ~= game.Name and fn ~= "") and "." .. fn or "") .. " is locked internally! Overwriting is not allowed!", 0)
			end

			if property ~= "_isService" and not rawget(self, "_isService") and not rawget(self, "____l")["_isService____l2"] then
				game.FrameworkService:CheckArgument(debug.traceback(), "SetProperty", 1, property, "string")
			end

			if rawget(self, "____l")[property .. "____l2"] or rawget(self, "____l")[property .. "____l3"] then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Property '" .. property .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
			end

			pcall(function() if Original.typeof(value) == "table" and value.XeptixFrameworkObject then value = value.____o end rawget(self,"____o")[property] = value end)
			return rawset(self, property, value)
		end,
		SetMethod = function(self, name, func)
			game.FrameworkService:CheckArgument("SetMethod", 2, func, "function")

			if superLockedProperties[name] then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Method '" .. name .. "' of game" .. ((fn ~= game.Name and fn ~= "") and "." .. fn or "") .. " is locked internally! Overwriting is not allowed!", 0)
			end

			if rawget(self, "____l")[name .. "____l2"] or rawget(self, "____l")[name .. "____l3"] then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Method '" .. name .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
			end

			return rawset(self, name, function(self, ...)
				return func(...)
			end)
		end,
		SetEvent = function(self, name)
			if superLockedProperties[name] then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Event '" .. name .. "' of game" .. ((fn ~= game.Name and fn ~= "") and "." .. fn or "") .. " is locked internally! Overwriting is not allowed!", 0)
			end

			if rawget(self, "____l")[name .. "____l2"] or rawget(self, "____l")[name .. "____l3"] then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Event '" .. name .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
			end

			rawset(self, name, RbxUtility:CreateSignal())
			return rawget(self, name)
		end,
		LockProperty = function(self, name, lockMode)
			if name ~= "_isService" and not rawget(self, "_isService") and not rawget(self, "____l")["_isService____l2"] then
				game.FrameworkService:CheckArgument(debug.traceback(), "LockProperty", 1, name, "string")
				game.FrameworkService:CheckArgument(debug.traceback(), "LockProperty", 2, lockMode, "number")
			end

			if lockMode < 1 or lockMode > 3 then ferror(debug.traceback(), "Argument #2 to 'LockProperty' must be a number from 1 to 3", 0) end
			if rawget(self, "____l")[name .. "____l" .. lockMode] ~= nil then
				local LType = {"Reading","Writing","Reading and Writing"}
				local fn = self:GetFullName()
				ferror(debug.traceback(), LType[lockMode] .. " property '" .. name .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is already locked!", 0)
			end

			local x;pcall(function()x=rawget(self, "____o")[name]end);
			if rawget(self, name) == false or x == false or rawget(self, "____l")[name .. "____l" .. lockMode] == false then
				rawget(self, "____l")[name .. "____l" .. lockMode] = false
			else
				rawget(self, "____l")[name .. "____l" .. lockMode] = rawget(self, "____l")[name .. "____l" .. lockMode] or rawget(self, name) or x
			end

			rawset(self, name, nil)
		end,
		GetProperties = function(self)
			local Properties = {}
			local trace
			trace = function(class)
				if APIDump[class] then
					for _,v in pairs(APIDump[class]) do
						if _:sub(1,2) == "1-" then
							pcall(function() Properties[_:sub(3)] = self[_:sub(3)] end)
						end
					end

					if APIDump[class].inheritance then
						trace(APIDump[class].inheritance)
					end
				end
			end

			trace(self.ClassName)

			return Properties
		end,
		GetMethods = function(self)
			local Methods = {}
			local trace
			trace = function(class)
				if APIDump[class] then
					for _,v in pairs(APIDump[class]) do
						if _:sub(1,2) == "2-" then
							pcall(function() Methods[_:sub(3)] = self[_:sub(3)] end)
						end
					end

					if APIDump[class].inheritance then
						trace(APIDump[class].inheritance)
					end
				end
			end

			trace(self.ClassName)

			return Methods
		end,
		GetEvents = function(self)
			local Events = {}
			local trace
			trace = function(class)
				if APIDump[class] then
					for _,v in pairs(APIDump[class]) do
						if _:sub(1,2) == "3-" then
							pcall(function() Events[_:sub(3)] = self[_:sub(3)] end)
						end
					end

					if APIDump[class].inheritance then
						trace(APIDump[class].inheritance)
					end
				end
			end

			trace(self.ClassName)

			return Events
		end,
		GetCallbacks = function(self)
			local Callbacks = {}
			local trace
			trace = function(class)
				if APIDump[class] then
					for _,v in pairs(APIDump[class]) do
						if _:sub(1,2) == "4-" then
							pcall(function() Callbacks[_:sub(3)] = true end)
						end
					end

					if APIDump[class].inheritance then
						trace(APIDump[class].inheritance)
					end
				end
			end

			trace(self.ClassName)

			return Callbacks
		end,
		IsXeptixFrameworkObject = function(self)
			return true
		end,
		XeptixFrameworkObject = true,
		____s = {},
		____l = {}
	},
	["DataModel"] = {
		GetService = function(self, ServiceName)
			if FrameworkServices[ServiceName] then
				return FrameworkServices[ServiceName]
			elseif FrameworkModule.Services:findFirstChild(ServiceName) then
				return LoadService(ServiceName)
			else
				return Object(rawget(self, "____o"):GetService(ServiceName))
			end
		end,
		IsFrameworkServiceLoaded = function(self, ServiceName)
			return FrameworkServices[ServiceName] and true
		end,
		FindService = function(self, ServiceName)
			if FrameworkServices[ServiceName] then
				return FrameworkServices[ServiceName] or false
			elseif FrameworkModule.Services:findFirstChild(ServiceName) then
				return LoadService(ServiceName) or false
			else
				return rawget(self, "____o"):FindService(ServiceName)
			end
		end,
		StartJob = function(self, Job)
			if FrameworkModule.Jobs:findFirstChild(Job) and not FrameworkJobs[Job] then
				FrameworkJobs[Job] = require(FrameworkModule.Jobs[Job])
				return FrameworkJobs[Job](Object(game), Object(game), Object(workspace), Object(workspace), table, string, math, typeof, type, Instance, print, require)
			end
		end,
		GetFrameworkModule = function(self)
			return FrameworkModule
		end,
		Is = function(self, condition)
			game.FrameworkService:CheckArgument(debug.traceback(), "Is", 1, condition, "string")

			if condition:lower() == "local" or condition:lower() == "localscript" or condition:lower() == "client" then
				return game:GetService("RunService"):IsClient()
			elseif condition:lower() == "studio" then
				return game:GetService("RunService"):IsStudio()
			elseif condition:lower() == "server" or condition:lower() == "script" then
				return game:GetService("RunService"):IsServer()
			elseif condition:lower() == "run" or condition:lower() == "runmode" or condition:lower() == "running" then
				return game:GetService("RunService"):IsRunMode()
			elseif condition:lower() == "connected" then
				return game.FrameworkHttpService.HttpEnabled and game.FrameworkHttpService.HttpConnected
			elseif condition:lower() == "full" then
				return game.Players.NumPlayers >= game.Players.MaxPlayers
			end

			return false
		end,
		CreateSignal = function(self)
			return RbxUtility:CreateSignal()
		end,
		GetDevice = function(self)
			local device = "Server"
			pcall(function()
				local uis = game:GetService("UserInputService")
				if uis.VREnabled then
					device = "VR"
				elseif uis.TouchEnabled and not uis.KeyboardEnabled then
					device = "Mobile"
				elseif uis.GamepadEnabled then
					device = "Console"
				else
					device = "PC"
				end
			end)

			return device
		end,
		___CachedSnowflakes = {},
		Snowflake = function(self)
			if self:Is("Connected") then
				if #self.___CachedSnowflakes >= 1 then
					local v = table.remove(self.___CachedSnowflakes, 1)

					return v or self:UUID()
				else
					local Snowflakes = game.FrameworkHttpService:Get("snowflake_batch", {json = true})
					if not Snowflakes or typeof(Snowflakes) ~= "table" or #Snowflakes <= 0 then return self:UUID() end

					self.___CachedSnowflakes = Snowflakes

					local SF = table.remove(self.___CachedSnowflakes, 1)

					return SF or self:UUID()
				end
			else
				return self:UUID()
			end
		end,
		UUID = function(self, format, symbols)
			if not format or type(format) ~= "string" then
				format = 'xxxxxxxx-yxxx-yxxx-xxxxxxxxxxxx'
			end

			if not symbols or type(symbols) ~= "table" or #symbols <= 0 then
				symbols = {"!","@","#","$","%","^","&","*","(",")","-","_","{","}","[","]","+","/","?",".",">","<",";",":"}
			end

			local random = math.random
			return string.gsub(format, '[xyz]', function (c)
				for i = 1,(math.ceil((tick() - math.floor(tick()))*25)) do random() end
				local v = (c == 'x') and random(0, 0xf) or ((c == 'z') and tostring(symbols[random(#symbols)]) or random(8, 0xb))
		        return c == 'z' and v or string.format('%x', v)
		    end):upper()
		end
	},
	["Players"] = {
		KickAll = function(self, msg)
			game.FrameworkService:CheckArgument(debug.traceback(), "KickAll", 1, msg, {"string", "nil"})

			game.FrameworkService:LockServer(debug.traceback(), "KickAll")

			for _,v in pairs(game.Players:GetPlayers()) do
				v:Kick(msg)
			end
		end
	},
	["Player"] = {
		LoadData = function(self, profile, nocache)
			game.FrameworkService:CheckArgument(debug.traceback(), "LoadData", 1, profile, {"number", "nil"})

			game.FrameworkService:LockServer(debug.traceback(), "LoadData")

			return game:GetService("PlayerDataService"):LoadData(self, profile, nocache)
		end,
		GetData = function(self, profile)
			game.FrameworkService:CheckArgument(debug.traceback(), "GetData", 1, profile, {"number", "nil"})

			if game:Is("Local") then
				return game:GetService("PlayerDataService").storage[self.userId .. "-" .. profile]
			end

			return game:GetService("PlayerDataService"):LoadData(self, profile)
		end,
		WaitForData = function(self, profile)
			game.FrameworkService:CheckArgument(debug.traceback(), "WaitForData", 1, profile, {"number", "nil"})

			return game:GetService("PlayerDataService"):WaitForData(self, profile)
		end,
		SaveData = function(self, profile)
			game.FrameworkService:CheckArgument(debug.traceback(), "SaveData", 1, profile, {"number", "nil"})

			game.FrameworkService:LockServer(debug.traceback(), "SaveData")

			return game:GetService("PlayerDataService"):SaveData(self, profile)
		end,
		DeleteData = function(self, profile)
			game.FrameworkService:CheckArgument(debug.traceback(), "DeleteData", 1, profile, {"number", "nil"})

			game.FrameworkService:LockServer(debug.traceback(), "DeleteData")

			return game:GetService("PlayerDataService"):DeleteData(self, profile)
		end,
		CloneData = function(self, profile, profile2)
			game.FrameworkService:CheckArgument(debug.traceback(), "CloneData", 1, profile, {"number", "nil"})
			game.FrameworkService:CheckArgument(debug.traceback(), "CloneData", 2, profile2, {"number", "nil"})

			game.FrameworkService:LockServer(debug.traceback(), "CloneData")

			return game:GetService("PlayerDataService"):CloneData(self, profile, profile2)
		end,
		UnloadData = function(self, profile)
			game.FrameworkService:CheckArgument(debug.traceback(), "UnloadData", 1, profile, {"number", "nil"})

			game.FrameworkService:LockServer(debug.traceback(), "UnloadData")

			return game:GetService("PlayerDataService"):UnloadData(self, profile)
		end
	}
}
StructureBase = {
	AdvancedTestingService = {"game", "workspace", "lighting", "players"}
}

ObjCache = {}
function Object(Obj)
	if ObjCache[Obj] then
		return ObjCache[Obj]
	end

	if Original.typeof(Obj) == "table" and Obj.XeptixFrameworkObject then
		return Obj
	end

	local Modified = {}
	for _,v in pairs(ModifiedObjects.root) do
		Modified[_] = v
	end

	if StructureBase[Obj.ClassName] then
		for _,v in pairs(StructureBase[Obj.ClassName]) do
			if ModifiedObjects[v] then
				for __, vv in pairs(ModifiedObjects[v]) do
					Modified[__] = vv
				end
			end
		end
	end

	if ModifiedObjects[Obj.ClassName] then
		for _,v in pairs(ModifiedObjects[Obj.ClassName]) do
			Modified[_] = v
		end
	end


	Modified.____o = Obj
	Modified.XeptixFrameworkObject = true
	Modified.____l = {}
	Modified.____e = {}
	Modified.____c = {}

	local NewObj
	NewObj = setmetatable(Modified, {
		__index = function(self, index)
			local l_ = rawget(self, "____l")
			if l_[index .. "____l1"] or l_[index .. "____l3"] and index ~= "GetFullName" then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Property '" .. index .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Reading is not allowed!", 0)
			elseif l_[index .. "____l2"] ~= nil then
				return l_[index .. "____l2"]
			end

			local v = rawget(self, index)
			if v ~= nil then
				return v
			else
				local o = Obj
				local value

				local ch = o:FindFirstChild(index)
				if ch then
					return Object(ch)
				end

				if not pcall(function()
					value = o[index]
					local vt = typeof(value)
					if vt == "function" then -- ok, methods, time to do some magic!
						value = function(self, ...)
							local a = {...}
							for i = 1,#a do
								local ot = Original.typeof(a[i])
								if ot == "table" and a[i].____o then
									a[i] = a[i].____o
								elseif ot == "table" then
									table.recursive(a[i], function(t, k, v)
										if Original.typeof(v) == "table" and v.____o then
											t[k] = v.____o
										end
									end)
								end
							end

							-- if you get an error here, it is not an error in the framework's code. ignore this line in the stack trace. this just redirects to roblox's api.
							local b = {o[index](o, unpack(a))}
							for i = 1,#b do
								local ot = typeof(b[i])
								if ot == "Instance" then
									b[i] = Object(b[i])
								elseif ot == "table" then
									table.recursive(b[i], function(t, k, v)
										if Original.typeof(v) == "Instance" then
											t[k] = Object(v)
										end
									end)
								end
							end

							return unpack(b)
						end
					elseif vt == "Instance" then
						value = Object(value)
					elseif vt == "RBXScriptSignal" then
						value = rawget(self, "____e")[index] or value
					end
				end) then
					ferror(debug.traceback(), index .. " is not a valid member of " .. self.ClassName, 0)
				end

				return value
			end
		end,
		__call = function(self) -- for now
			ferror(debug.traceback(), "Attempt to call " .. self.ClassName)
		end,
		__newindex = function(self, index, value)
			local c_ = rawget(self, "____c")
			if c_[index] then
				if Obj:IsA("MarketplaceService") and index:lower() == "processreceipt" then
					local ms = Obj
					local oms = self
					local r_ = rawget(self, "_receipts")
					if r_ then
						table.insert(r_, value)
						rawset(self, "_receipts", r_)
					else
						rawset(self, "_receipts", {value})
						ms[index] = function(Receipt)
							local Decision = Enum.ProductPurchaseDecision.NotProcessedYet
							for _,v in pairs(oms._receipts) do
								local r = v(Receipt)
								if Decision ~= r and (r == Enum.ProductPurchaseDecision.PurchaseGranted or r == "framework.internal") then
									Decision = r
								end
							end

							if Decision == Enum.ProductPurchaseDecision.PurchaseGranted then

							end

							return Decision
						end
					end
				else
					Obj[index] = function(...)
						local a = {...}
						for _,v in pairs(a) do
							if typeof(v) == "Instance" then
								a[_] = Object(v)
							end
						end

						return value(unpack(a))
					end
				end
			else
				local p_ = rawget(self, index)
				local l_ = rawget(self, "____l")
				if l_[index .. "____l2"] or l_[index .. "____l3"] then
					local fn = self:GetFullName()
					ferror(debug.traceback(), "Property '" .. index .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
				end--

				if Original.typeof(value) == "table" and value.XeptixFrameworkObject then
					value = value.____o
				end

				pcall(function() Obj[index] = value end)
				if p_ ~= nil then
					rawset(self, index, value)
				end
			end
		end,
		__metatable = function()
			return Modified.____o
		end,
		__concat = function(self, value)
			return self.Name .. value
		end,
		__len = function(self)
			return #rawget(self, "____o"):GetChildren()
		end,
		-- All of the below metamethods will throw errors.
		-- Notice: this is not a framework issue, you can not perform mathematics on instances broski.
		__add = function(self, value)
			return rawget(self, "____o") + value
		end,
		__sub = function(self, value)
			return rawget(self, "____o") - value
		end,
		__mul = function(self, value)
			return rawget(self, "____o") * value
		end,
		__div = function(self, value)
			return rawget(self, "____o") / value
		end,
		__mod = function(self, value)
			return rawget(self, "____o") % value
		end,
		__pow = function(self, value)
			return rawget(self, "____o") ^ value
		end,
		__eq = function(self, value)
			return rawget(self, "____o") == value
		end,
		__lt = function(self, value)
			return rawget(self, "____o") < value
		end,
		__le = function(self, value)
			return rawget(self, "____o") <= value
		end
	})

	rawset(NewObj, "____c", NewObj:GetCallbacks())

	Obj.Changed:connect(function()
		if not Obj.Parent then
			ObjCache[Obj] = nil
			pcall(function()
				for _,v in pairs(rawget(NewObj, "____e")) do v:softdisconnect() end
			end)
		elseif Obj.Parent and not ObjCache[Obj] then
			ObjCache[Obj] = NewObj
		end
	end)

	--if NewObj.ClassName ~= "DataModel" then
		for _,v in pairs(NewObj:GetEvents()) do -- hacky event stuff yay!!!
			pcall(function()
				local rbx = NewObj[_]
				if typeof(rbx) == "RBXScriptSignal" then
					--local signal = RbxUtility:CreateSignal()
					--local c = signal.connect;
					local signal = {}
					local first
					local hah = {}
					function signal:connect(f)
						local rc = rbx:connect(function(...)
							local hax = {...}
							for hi,mate in pairs(hax) do
								if typeof(mate) == "Instance" then
									hax[hi] = Object(mate)
								end
							end

							f(unpack(hax))
						end)

						hah[f] = rc

						return rc
					end
					function signal:Connect(f)
						return signal:connect(f)
					end
					function signal:wait(f)
						return rbx:wait(f)
					end
					function signal:Wait(f)
						return signal:wait(f)
					end
					function signal:Fire(...)
						return signal:fire(...)
					end
					function signal:Disconnect()
						return signal:disconnect()
					end
					function signal:fire(...)
						for _,v in pairs(hah) do
							if _ and v and v.Connected then
								_(...)
							else
								hah[_] = nil
							end
						end
					end
					function signal:disconnect()
						for _,v in pairs(hah) do
							if _ and v and v.Connected then
								v:disconnect()
							else
								hah[_] = nil
							end
						end
					end
					function signal:softdisconnect()
						hah = {}
					end
					rawget(NewObj, "____e")[_] = signal
				end
			end)
		end
	--end

	ObjCache[Obj] = NewObj
	return NewObj
end

function CreateService(Name, Class, Service, Hidden)
	local S
	pcall(function() S = Object(Original.game:GetService(Name)) end)
	S = S or Object(Instance.new(Hidden == true and "Snap" or "Motor"))
	S.Parent = game
	S.Archivable = false
	FrameworkServices[Name] = S
	FrameworkServices[Class] = S
	
	if Hidden and false then -- meh
		Object(Original.game):SetProperty(Name, S)
		S.Parent = FrameworkModule
	end

	pcall(function() S:SetProperty("_isService", true)
	S:SetProperty("ClassName", Class)
	S:SetProperty("SuperClassName", "XeptixFrameworkService")
	S.Name = Name
	S:SetProperty("XeptixFrameworkService", true)
	S:SetProperty("ServiceStarted", false)
	--
	S:LockProperty("_isService", 2)
	S:LockProperty("ClassName", 2)
	S:LockProperty("SuperClassName", 2)
	S:LockProperty("XeptixFrameworkService", 2)
	S:LockProperty("Name", 2)
	S:LockProperty("Clone", 3)
	S:LockProperty("Remove", 3)
	S:LockProperty("remove", 3)
	S:LockProperty("Destroy", 3)
	S:LockProperty("destroy", 3)
	S:LockProperty("ClearAllChildren", 3)

	for _,v in pairs(Service) do
		S:SetProperty(_, v)
		if typeof(v) == "function" or typeof(v) == "RBXScriptSignal" then
			S:LockProperty(_, 2)
		end
	end end)

	return S
end

function LoadService(name)
	local Service = require(FrameworkModule.Services[name])
	local ServiceObject = CreateService(Service[1], Service[2], Service[3], Service[4])
	ServiceObject:_StartService(Object(game), Object(game), Object(workspace), Object(workspace), table, string, math, typeof, type, Instance, print, require, ferror, tostring)

	return ServiceObject
end

function NewMeta(meta, modified)
	return setmetatable(modified, {
		__index = function(self, index, value)
			if rawget(self, index) then
				return rawget(self, index)
			else
				return rawget(meta, index)
			end
		end
	})
end

-- Credit to Crazyman32
-- GetDate function
function GetDate(atick)
	local date = {}
	local months = {
		{"January", 31};
		{"February", 28};
		{"March", 31};
		{"April", 30};
		{"May", 31};
		{"June", 30};
		{"July", 31};
		{"August", 31};
		{"September", 30};
		{"October", 31};
		{"November", 30};
		{"December", 31};
	}
	local t = atick or tick()
	date.total = t
	date.seconds = math.floor(t % 60)
	date.minutes = math.floor((t / 60) % 60)
	date.hours = math.floor((t / 60 / 60) % 24)
	date.year = (1970 + math.floor(t / 60 / 60 / 24 / 365.25))
	date.yearShort = tostring(date.year):sub(-2)
	date.isLeapYear = ((date.year % 4) == 0)
	date.isAm = (date.hours < 12)
	date.hoursPm = (date.isAm and date.hours or (date.hours == 12 and 12 or (date.hours - 12)))
	if (date.hoursPm == 0) then date.hoursPm = 12 end
	if (date.isLeapYear) then
		months[2][2] = 29
	end
	do
		date.dayOfYear = math.floor((t / 60 / 60 / 24) % 365.25)
		local dayCount = 0
		for i,month in pairs(months) do
			dayCount = (dayCount + month[2])
			if (dayCount > date.dayOfYear) then
				date.monthWord = month[1]
				date.month = i
				date.day = (date.dayOfYear - (dayCount - month[2]) + 1)
				break
			end
		end
	end
	function date:format(str)
		str = str
			:gsub("#s", ("%.2i"):format(self.seconds))
			:gsub("#m", ("%.2i"):format(self.minutes))
			:gsub("#h", tostring(self.hours))
			:gsub("#H", tostring(self.hoursPm))
			:gsub("#Y", tostring(self.year))
			:gsub("#y", tostring(self.yearShort))
			:gsub("#a", (self.isAm and "AM" or "PM"))
			:gsub("#W", self.monthWord)
			:gsub("#M", tostring(self.month))
			:gsub("#d", tostring(self.day))
			:gsub("#D", tostring(self.dayOfYear))
			:gsub("#t", tostring(self.total))
		  -- ^ me gusta coding style -Xeptix
		return str
	end
	return date
end

-- Finalization
game = Object(Original.game)
Game = game
workspace = Object(Original.workspace)
Workspace = workspace
table = NewMeta(Original.table, {
	format = function(t, f, j)
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 2, f, "string")
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 3, j, {"string", "nil"})

		local n = {}
		local numa, numb = #t, 0
		if #t < 100 then
			for _,v in pairs(t) do numb = numb + 1 end
		end

		local function proceed(i, v)
			local s = f:gsub("%%i", tostring(i)):gsub("%%v", tostring(v))
			table.insert(n, s)
		end

		if #t >= 100 or numa == numb then -- list it in order
			for i = 1, #t do
				proceed(i, t[i])
			end
		else -- pairs
			for i,v in pairs(t) do
				proceed(i, v)
			end
		end

		return table.join(n, j or " ")
	end,
	join = function(t, j)
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 2, j, "string")

		local s = ""
		local numa, numb = #t, 0
		if #t < 100 then
			for _,v in pairs(t) do numb = numb + 1 end
		end

		if #t >= 100 or numa == numb then -- list in order
			for i = 1, #t do
				s = s .. tostring(t[i]) .. (#t == i and "" or j)
			end
		else -- pairs
			for i,v in pairs(t) do
				s = s .. tostring(v) .. j
			end

			s = s:sub(0, s.length - j.length)
		end

		return s
	end,
	recursive = function(t, f)
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 2, f, "function")

		for i,v in pairs(t) do
			f(t, i, v)

			if typeof(v) == "table" then
				table.recursive(v, f)
			end
		end
	end,
	random = function(t)
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")

		if #t == 0 then
			local x = {}
			for _,v in pairs(t) do table.insert(x,v) end

			if #x == 0 then return end

			return x[math.random(#x)]
		end

		return t[math.random(#t)]
	end,
	exists = function(t, n)
		game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")
		
		for i,v in pairs(t) do
			if v == n then
				return i
			end
		end
		
		return nil
	end

})
string = NewMeta(Original.string, {
	split = function(str, delim, maxNb)
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, str, "string")
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 2, delim, "string")
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 3, maxNb, {"number", "nil"})

	   delim = "%" .. delim
	    -- Eliminate bad cases...
	   if string.find(str, delim) == nil then
	      return { str }
	   end
	   if maxNb == nil or maxNb < 1 then
	      maxNb = 0    -- No limit
	   end
	   local result = {}
	   local pat = "(.-)" .. delim .. "()"
	   local nb = 0
	   local lastPos
	   for part, pos in string.gmatch(str, pat) do
	      nb = nb + 1
	      result[nb] = part
	      lastPos = pos
	      if nb == maxNb then
	         break
	      end
	   end
	   -- Handle the last field
	   if nb ~= maxNb then
	      result[nb + 1] = string.sub(str, lastPos)
	   end
	   return result
	end,
	time = function(Time, Limit, ShortLimit) -- todo: rewrite, from 2015 framework lol
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, Time, "number")
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 2, Limit, {"number", "nil"})
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 3, ShortLimit, {"number", "nil"})
		
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
		
		return TimeStr
	end,
	timestamp = function(Timestamp, Format)
	    game.FrameworkService:CheckArgument(debug.traceback(), nil, 3, Timestamp, {"number", "nil"})
	    game.FrameworkService:CheckArgument(debug.traceback(), nil, 3, Format, {"string", "nil"})
	
		return GetDate(Timestamp or os.time()):format(Format or "#M/#d/#Y #H:#m #a")
	end
})
math = NewMeta(Original.math, {
	format = function(Number, AD)
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, Number, "number")
	
		local D = ""
		Number = tonumber(tostring(Number)) or (Number > 2147483247 and 2147483247 or (Number < -2147483247 and -2147483247 or 0))
		if not AD then
			Number = math.floor(Number)
		else
			D = tostring(Number-math.floor(Number)):sub(2)
			Number = math.floor(Number)
		end
		
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
		
		
		return (Neg and "-" or "") .. Str:reverse() .. D
	end,
	abbreviate = function(number)
	   game.FrameworkService:CheckArgument(debug.traceback(), nil, 1, number, "number")
	
		local oN = tostring(math.floor(number))
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
		
		return abrv
	end
})
typeof = function(x)
	if Original.typeof(x) == "table" and x.XeptixFrameworkObject then
		return "Instance"
	else
		return Original.typeof(x)
	end
end
type = function(x)
	if Original.typeof(x) == "table" and x.XeptixFrameworkObject then
		return Original.type(x.____o)
	else
		return Original.type(x)
	end
end
local customInstances = {}
Instance = {
	new = function(c, p)
		local custom = customInstances[tostring(c)]
		if custom then
			local i = Object(Instance.new("Folder"))
			i:SetProperty("ClassName", tostring(c))
			i:SetProperty("SuperClassName", tostring(c))
			if typeof(custom) == "table" then
				for _,v in pairs(custom) do
					if typeof(v) == "function" then
						i:SetMethod(tostring(_), v)
					elseif typeof(v):lower() == "signal" then
						i:SetEvent(tostring(_))
					else
						i:SetProperty(tostring(_), v)
					end
				end
			elseif typeof(custom) == "function" then
				custom(i)
			end

			i.Parent = p
			return i
		end

		if Original.typeof(p) == "table" and p.XeptixFrameworkObject then
			p = p.____o
		end

		local x = Original.Instance.new(tostring(c))
		x.Parent = p -- check rbxdev, it is inefficient to use the parent argument in Instance.new - this helps speed your game up! :D
		return Object(x)
	end,
	create = function(c, p)
		customInstances[tostring(c)] = p ~= nil and p or true
	end
}
print = function(...)
	local a = {...}
	local b = {}
	for i = 1,#a do
		local v = a[i]
		if Original.typeof(v) == "table" and v.XeptixFrameworkObject then
			v = v.____o
		end

		table.insert(b, v)
	end

	Original.print(unpack(b))
end
require = function(module)
	if Original.typeof(module) == "table" and module.XeptixFrameworkObject then
		module = module.____o
	end

	return Original.require(module)
end
ferror = function(stack, err)
	-- NOTE: if you got an error here, it is NOT a framework error. Ignore all lines in the stack trace that go to the framework's scripts. Typically the very bottom script(s) are the ones where the actual error was triggered. More info on this in documentation.
	if typeof(stack) ~= "string" then error(err or "???", 0) end

	local yourStack
	for line in stack:gmatch("([^\r\n]*)[\r\n]") do
		if not line:find(FrameworkModule:GetFullName()) and line ~= "Stack End" and line ~= "Stack Begin" and line ~= "" then
			yourStack = line
			break
		end
	end

	-- NOTE: if you got an error here, it is NOT a framework error. Ignore all lines in the stack trace that go to the framework's scripts. Typically the very bottom script(s) are the ones where the actual error was triggered. More info on this in documentation.
	error(err .. (yourStack and ("\n" .. yourStack) or ""), 0)
end
tostring = function(str)
	if Original.typeof(str) == "table" and str.____o then
		return Original.tostring(str.____o)
	end

	return Original.tostring(str)
end



-- Initalize the framework's core
FrameworkService = game:StartJob("Core")



-- Return the function to modify the environment
return function(sf, environment)
	environment.game = game
	environment.Game = game
	environment.workspace = game.Workspace
	environment.Workspace = game.Workspace
	environment.Instance = Instance
	environment.print = print
	environment.require = require
	environment.type = type
	environment.typeof = typeof
	environment.table = table
	math.randomseed(tick())
	environment.math = math
	environment.string = string
	environment.tostring = tostring

	sf(0, environment)
end
