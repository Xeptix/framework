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







FrameworkModule = game.ReplicatedStorage.XeptixFramework
_FrameworkSecurity = "asduht34uyu234gujguaw474aiowea4yerh" -- todo: make plugin randomize this each install
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
RbxUtility = LoadLibrary("RbxUtility")
ModifiedObjects = {
	["root"] = {
		IsA = function(self, ClassName)
			if ClassName == "XeptixFrameworkService" then
				return self.XeptixFrameworkService
			elseif ClassName == "XeptixObject" then
				return true
			elseif rawget(self, "ClassName") == ClassName then
				return true
			else
				return rawget(self, "____o"):IsA(ClassName)
			end
		end,
		FindFirstChild = function(self, ClassName, Recursive)
			game.FrameworkService:CheckArgument("FindFirstChildOfClass", 1, ClassName, "string")
			game.FrameworkService:CheckArgument("FindFirstChildOfClass", 2, Recursive, {"boolean", "nil"})
			
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
			game.FrameworkService:CheckArgument("FindFirstChildOfClass", 1, ClassName, "string")
			game.FrameworkService:CheckArgument("FindFirstChildOfClass", 2, Recursive, {"boolean", "nil"})
			
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
			game.FrameworkService:CheckArgument("FindFirstChildOfClass", 1, Name, "string")
			game.FrameworkService:CheckArgument("FindFirstChildOfClass", 3, Recursive, {"boolean", "nil"})
			
			if Recursive then
				Object:Recursive(function(v)
					if v:CanReadProperty(Name) and v[Name] == Value then
						return
					end
				end)
			else
				for _,v in pairs(self:GetChildren()) do
					
				end
			end
		end,
		findFirstChildWithProperty = function(self, ...)
			return rawget(self, "FindFirstChildWithProperty")(self, ...)
		end,
		WaitForChild = function(self, Name, Timeout)
			local O = rawget(self, "____o"):WaitForChild(Name, Timeout)
			if O then
				O = Object(O)
			end
			
			return O
		end,
		waitForChild = function(self, ...)
			return rawget(self, "WaitForChild")(self, ...)
		end,
		
		CanReadProperty = function(self, name)
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
			local can = true
			if rawget(self, "____l")[name .. "____l2"] or rawget(self, "____l")[name .. "____l3"] then
				can = false
			end
			
			return can
		end,
		HasProperty = function(self, name)
			game.FrameworkService:CheckArgument("HasProperty", 1, name, "string")
			
			return (rawget(self, name) or rawget(self, "____l")[name .. "____l2"] or pcall(function() local x = rawget(self, "____o")[name] end)) and true or false
		end,
		HasMethod = function(self, name)
			game.FrameworkService:CheckArgument("HasMethod", 1, name, "string")
			
			return (rawget(self, name) or rawget(self, "____l")[name .. "____l2"] or pcall(function() local x = rawget(self, "____o")[name] end)) and true or false
		end,
		HasEvent = function(self, name)
			game.FrameworkService:CheckArgument("HasEvent", 1, name, "string")
			
			return (rawget(self, name) or rawget(self, "____l")[name .. "____l2"] or pcall(function() local x = rawget(self, "____o")[name] end)) and true or false
		end,
		SetProperty = function(self, property, value)
			if superLockedProperties[property] then
				local fn = self:GetFullName()
				error("Property '" .. property .. "' of game" .. ((fn ~= game.Name and fn ~= "") and "." .. fn or "") .. " is locked internally! Overwriting is not allowed!", 0)
			end
			
			if property ~= "_isService" and not rawget(self, "_isService") and not rawget(self, "____l")["_isService____l2"] then
				game.FrameworkService:CheckArgument("SetProperty", 1, property, "string")
			end
			
			if rawget(self, "____l")[property .. "____l2"] or rawget(self, "____l")[property .. "____l3"] then
				local fn = self:GetFullName()
				error("Property '" .. property .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
			end
			
			pcall(function() if Original.typeof(value) == "table" and value.XeptixFrameworkObject then value = value.____o end rawget(self,"____o")[property] = value end)
			return rawset(self, property, value)
		end,
		SetMethod = function(self, name, func)
			if superLockedProperties[name] then
				local fn = self:GetFullName()
				error("Method '" .. name .. "' of game" .. ((fn ~= game.Name and fn ~= "") and "." .. fn or "") .. " is locked internally! Overwriting is not allowed!", 0)
			end
			
			if rawget(self, "____l")[name .. "____l2"] or rawget(self, "____l")[name .. "____l3"] then
				local fn = self:GetFullName()
				error("Method '" .. name .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
			end
			
			return rawset(self, name, function(self, ...)
				return func(...)
			end)
		end,
		SetEvent = function(self, name)
			if superLockedProperties[name] then
				local fn = self:GetFullName()
				error("Event '" .. name .. "' of game" .. ((fn ~= game.Name and fn ~= "") and "." .. fn or "") .. " is locked internally! Overwriting is not allowed!", 0)
			end
			
			if rawget(self, "____l")[name .. "____l2"] or rawget(self, "____l")[name .. "____l3"] then
				local fn = self:GetFullName()
				error("Event '" .. name .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
			end
			
			rawset(self, name, RbxUtility:CreateSignal())
			return rawget(self, name)
		end,
		LockProperty = function(self, name, lockMode)
			if name ~= "_isService" and not rawget(self, "_isService") and not rawget(self, "____l")["_isService____l2"] then
				game.FrameworkService:CheckArgument("LockProperty", 1, name, "string")
				game.FrameworkService:CheckArgument("LockProperty", 2, lockMode, "number")
			end
			
			if lockMode < 1 or lockMode > 3 then error("Argument #2 to 'LockProperty' must be a number from 1 to 3", 0) end
			if rawget(self, "____l")[name .. "____l" .. lockMode] then
				local LType = {"Reading","Writing","Reading and Writing"}
				local fn = self:GetFullName()
				error(LType[lockMode] .. " property '" .. name .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is already locked!", 0)
			end
			local x;pcall(function()x=rawget(self, "____o")[name]end);
			rawget(self, "____l")[name .. "____l" .. lockMode] = rawget(self, "____l")[name .. "____l" .. lockMode] or rawget(self, name) or x
			rawset(self, name, nil)
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
				FrameworkJobs[Job](Object(game), Object(game), Object(workspace), Object(workspace), table, string, math, typeof, type, Instance, print, require)
			end
		end,
		GetFrameworkModule = function(self)
			return FrameworkModule
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
				error("Property '" .. index .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Reading is not allowed!", 0)
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
					error(index .. " is not a valid member of " .. self.ClassName, 0)
				end
				
				return value
			end
		end,
		__call = function(self) -- for now
			error("Attempt to call " .. self.ClassName)
		end,
		__newindex = function(self, index, value)
			if rawget(self, "____l")[index .. "____l2"] or rawget(self, "____l")[index .. "____l3"] then
				local fn = self:GetFullName()
				error("Property '" .. index .. "' of " .. ((fn ~= Original.game.Name) and "game." .. fn or "DataModel") .. " is locked! Writing is not allowed!", 0)
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
	local S = Object(Instance.new("Configuration", game))
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
	ServiceObject:_StartService(Object(game), Object(game), Object(workspace), Object(workspace), table, string, math, typeof, type, Instance, print, require)

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
FrameworkService = nil
spawn(function() FrameworkService = game:GetService("FrameworkService") end)
table = NewMeta(Original.table, {
	format = function(t, f, j)
		FrameworkService:CheckArgument(nil, 1, t, "table")
		FrameworkService:CheckArgument(nil, 2, f, "string")
		FrameworkService:CheckArgument(nil, 3, j, {"string", "nil"})
		
		local n = {}
		local numa, numb = #t, 0
		if #t < 100 then
			for _,v in ipairs(t) do numb = numb + 1 end
		end
		
		local function proceed(i, v)
			table.insert(n, f:gsub("%%i", tostring(i)):gsub("%%v", tostring(v)))
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
		FrameworkService:CheckArgument(nil, 1, t, "table")
		FrameworkService:CheckArgument(nil, 2, j, "string")
		
		local s = ""
		local numa, numb = #t, 0
		if #t < 100 then
			for _,v in ipairs(t) do numb = numb + 1 end
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
		FrameworkService:CheckArgument(nil, 1, t, "table")
		FrameworkService:CheckArgument(nil, 2, f, "function")
		
		for i,v in pairs(t) do
			f(t, i, v)
			
			if typeof(v) == "table" then
				table.recursive(v, f)
			end
		end
	end
	
})
string = NewMeta(Original.string, {
	
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


-- Initalize the framework's core
game:StartJob("Core")



-- Return the modified variables
return {game, game, workspace, workspace, table, string, math, typeof, type, Instance, print, require}