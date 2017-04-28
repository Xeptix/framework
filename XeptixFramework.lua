-- Xeptix Framework 3.0.0a
-- Documentation: https://github.com/xeptix/framework/wiki
-- Website: https://framework.xeptix.com
-- This framework is designed to help you out with development by adding many awesome services, and allowing you to create
-- your own custom properties, methods, and events for all objects. These work cross-script, but server/client do not share these
-- even if you're not using Filtering Enabled.
-- Supports all games, both group and personal, with all settings (including fe/non-fe).


------> You are not currently connected to our webservers! <------
-- Some features require you to connect your game to our website (https://framework.xeptix.com/connect)
-- Make sure HttpService is enabled if you choose to do so. Features that require a connection to our webservers will throw an error.
-------------> It is advised that you connect your game! <-------------


-- Do not edit this script, as when the framework updates your changes will be erased.
---> Do feel free to create your own services and jobs, but only do so if you are an advanced scripter. <---
-- Making a backup is not a bad idea.



-- Check out our github to view documentation, add to the framework, or fix bugs yourself! https://github.com/xeptix/framework
-- Always be sure to read documentation if it is your first time using a feature - all information you need is displayed there!








FrameworkModule = game:findFirstChild(".xeptixframework.", true).Parent
Original = {["require"] = require, ["print"] = print, ["Instance"] = Instance, ["typeof"] = typeof, ["type"] = type, ["game"] = game, ["Game"] = game, ["Workspace"] = workspace, ["workspace"] = workspace, ["math"] = math, ["table"] = table, ["string"] = string}
FrameworkServices = {}
FrameworkJobs = {}
superLockedProperties = {}
superLockedProperties.____o = true
superLockedProperties.____l = true
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
		end,
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
			if rawget(self, "____l")[name .. "____l" .. lockMode] then
				local LType = {"Reading","Writing","Reading and Writing"}
				local fn = self:GetFullName()
				ferror(debug.traceback(), LType[lockMode] .. " property '" .. name .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is already locked!", 0)
			end
			
			local x;pcall(function()x=rawget(self, "____o")[name]end);
			rawget(self, "____l")[name .. "____l" .. lockMode] = rawget(self, "____l")[name .. "____l" .. lockMode] or rawget(self, name) or x
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
						if _:sub(1,2) == "2-" then
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
						if _:sub(1,2) == "2-" then
							pcall(function() Callbacks[_:sub(3)] = self[_:sub(3)] end)
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
				return rawget(self, "____o"):GetService(ServiceName)
			end
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
		end
	},
	["Player"] = {
		LoadData = function(self, profile, nocache)
			game.FrameworkService:CheckArgument(debug.traceback(), "LoadData", 1, profile, {"number", "nil"})
			
			game.FrameworkService:LockServer(debug.stack(), "LoadData")

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
			
			game.FrameworkService:LockServer(debug.stack(), "SaveData")

			return game:GetService("PlayerDataService"):SaveData(self, profile)
		end,
		DeleteData = function(self, profile)
			game.FrameworkService:CheckArgument(debug.traceback(), "DeleteData", 1, profile, {"number", "nil"})
			
			game.FrameworkService:LockServer(debug.stack(), "DeleteData")

			return game:GetService("PlayerDataService"):DeleteData(self, profile)
		end,
		CloneData = function(self, profile, profile2)
			game.FrameworkService:CheckArgument(debug.traceback(), "CloneData", 1, profile, {"number", "nil"})
			game.FrameworkService:CheckArgument(debug.traceback(), "CloneData", 2, profile2, {"number", "nil"})
			
			game.FrameworkService:LockServer(debug.stack(), "CloneData")

			return game:GetService("PlayerDataService"):CloneData(self, profile, profile2)
		end,
		UnloadData = function(self, profile)
			game.FrameworkService:CheckArgument(debug.traceback(), "UnloadData", 1, profile, {"number", "nil"})
			
			game.FrameworkService:LockServer(debug.stack(), "UnloadData")

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
	Modified.____l = {}
	
	local NewObj
	NewObj = setmetatable(Modified, {
		__index = function(self, index)
			if rawget(self, "____l")[index .. "____l1"] or rawget(self, "____l")[index .. "____l3"] and index ~= "GetFullName" then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Property '" .. index .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Reading is not allowed!", 0)
			elseif rawget(self, "____l")[index .. "____l2"] then
				return rawget(self, "____l")[index .. "____l2"]
			end
			
			local v = rawget(self, index)
			if v ~= nil then
				return v
			else
				local o = rawget(self, "____o")
				local value
				
				if o:FindFirstChild(index) then
					return Object(o:FindFirstChild(index))
				end
				
				if not pcall(function()
					value = o[index]
					if typeof(value) == "function" then -- ok, methods, time to do some magic!
						value = function(self, ...)
							local a = {...}
							for i = 1,#a do
								if typeof(a[i]) == "Instance" and a[i]:IsA("XeptixObject") then
									a[i] = a[i].____o
								elseif typeof(a[i]) == "table" then
									table.recursive(a[i], function(t, k, v)
										if typeof(v) == "Instance" and v:IsA("XeptixObject") then
											t[k] = v.____o
										end
									end)
								end
							end
							
							-- if you get an error here, it is not an error in the framework's code. ignore this line in the stack trace. this just redirects to roblox's api.
							local b = {o[index](o, unpack(a))}
							for i = 1,#b do
								if typeof(b[i]) == "Instance" then
									b[i] = Object(b[i])
								elseif typeof(b[i]) == "table" then
									table.recursive(b[i], function(t, k, v)
										if typeof(v) == "Instance" then
											t[k] = Object(v)
										end
									end)
								end 
							end
							
							return unpack(b)
						end
					elseif typeof(value) == "Instance" then
						value = Object(value)
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
			if rawget(self, "____l")[index .. "____l2"] or rawget(self, "____l")[index .. "____l3"] then
				local fn = self:GetFullName()
				ferror(debug.traceback(), "Property '" .. index .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
			end
			
			if Original.typeof(value) == "table" and value.XeptixFrameworkObject then
				value = value.____o
			end
			
			rawget(self, "____o")[index] = value
		end,
		__metatable = function()
			return Modified.____o
		end,
		__concat = function(self, value)
			return self.Name .. value
		end,
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
		end,
		__len = function(self)
			return #rawget(self, "____o"):GetChildren()
		end
	})
	
	Obj.Changed:connect(function()
		if not Obj.Parent then
			ObjCache[Obj] = nil
		elseif Obj.Parent and not ObjCache[Obj] then
			ObjCache[Obj] = NewObj
		end
	end)
	
	ObjCache[Obj] = NewObj
	return NewObj
end

function CreateService(Name, Class, Service)
	local S
	pcall(function() S = game:FindFirstChild(Name) end)
	S = S or Object(Instance.new("Configuration", game))
	FrameworkServices[Name] = S
	FrameworkServices[Class] = S
	
	pcall(function() S:SetProperty("_isService", true)
	S:SetProperty("ClassName", Class)
	S:SetProperty("SuperClassName", "XeptixFrameworkService")
	S.Name = Name
	S:SetProperty("XeptixFrameworkService", true)
	S:SetProperty("ServiceStarted", false)
	
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
	local ServiceObject = CreateService(Service[1], Service[2], Service[3])
	ServiceObject:_StartService(Object(game), Object(game), Object(workspace), Object(workspace), table, string, math, typeof, type, Instance, print, require, ferror)

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

-- Finalization
game = Object(Original.game)
Game = game
workspace = Object(Original.workspace)
Workspace = workspace
table = NewMeta(Original.table, {
	format = function(t, f, j)
		FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")
		FrameworkService:CheckArgument(debug.traceback(), nil, 2, f, "string")
		FrameworkService:CheckArgument(debug.traceback(), nil, 3, j, {"string", "nil"})
		
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
		FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")
		FrameworkService:CheckArgument(debug.traceback(), nil, 2, j, "string")
		
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
		FrameworkService:CheckArgument(debug.traceback(), nil, 1, t, "table")
		FrameworkService:CheckArgument(debug.traceback(), nil, 2, f, "function")
		
		for i,v in pairs(t) do
			f(t, i, v)
			
			if typeof(v) == "table" then
				table.recursive(v, f)
			end
		end
	end
	
})
string = NewMeta(Original.string, {
	split = function(str, delim, maxNb)
	   FrameworkService:CheckArgument(debug.traceback(), nil, 1, str, "string")
	   FrameworkService:CheckArgument(debug.traceback(), nil, 2, delim, "string")
	   FrameworkService:CheckArgument(debug.traceback(), nil, 3, maxNb, {"number", "nil"})
	   
	   str = "%" .. str
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
	end
})
math = NewMeta(Original.math, {
	
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
Instance = {
	new = function(c, p)
		if Original.typeof(p) == "table" and p.XeptixFrameworkObject then
			p = p.____o
		end
		
		local x = Original.Instance.new(c, p)
		return Object(x)
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



-- Initalize the framework's core
FrameworkService = game:StartJob("Core")



-- Return the function to modify the environment
return function(environment)
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
	environment.math = math
	environment.string = string
	environment.script = Object(environment.script)
	
	return environment
end