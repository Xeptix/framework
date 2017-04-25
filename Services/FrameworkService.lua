-- Core framework service.

return {"FrameworkService", "FrameworkService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l, m)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require, ferror = a, b, c, d, e, f, g, h, i, j, k, l, m

		self:DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Output = function(self, ...)
		print("[ Framework ]", ...)
	end,
	debugMode = false,
	DebugOutput = function(self, ...)
		if not self.debugMode then return end
		
		print("[ Framework *D ]", ...)
	end, 
	CheckArgument = function(self, stack, func, arg, got, expecting)
		local t = typeof(got)
		
		if typeof(expecting) == "table" then
			local goodToGo = false 
			
			for _,v in pairs(expecting) do
				if t == v then
					goodToGo = true
					break
				end
			end
			
			if not goodToGo then
				ferror(stack, "bad argument #" .. arg .. " to '" .. (func or "?") .. "' (" .. table.join(expecting, ",", "or") .. " expected, got " .. t .. ")", 0)
			end
		else -- NOTE: if you got an error here, it is NOT a framework error. Ignore all lines in the stack trace that go to the framework's scripts. Typically the very bottom script(s) are the ones where the actual error was triggered. More info on this in documentation.
			if t ~= expecting then
				ferror(stack, "bad argument #" .. arg .. " to '" .. (func or "?") .. "' (" .. expecting .. " expected, got " .. t .. ")", 0)
			end
		end
	end,
	Serialize = function(self, x)
		local s = {}
		
		if typeof(x) == "Instance" then
			s._____serialized = "Instance"
			s.x = {}
			for i,v in pairs(x:GetProperties()) do
				if i ~= "Parent" then
					s.x[i] = self:Serialize(v)
				end
			end
			
			x.c = {}
			for _,v in pairs(x:GetChildren()) do
				table.insert(x.c, self:Serialize(v))
			end
		elseif typeof(x) == "table" then
			s._____serialized = "table"
			s.x = x
		else
			s._____serialized = typeof(x)
			s.x = tostring(x)
		end
		
		return game.HttpService:JSONEncode(s)
	end,
	Unserialize = function(self, x)
		local s
		pcall(function()
			s = game.HttpService:JSONDecode(x)
		end)
		
		if s and typeof(s) == "table" and s._____serialized and s.x then
			if s._____serialized == "table" or s._____serialized == "string" then
				return s.x
			elseif s._____serialized == "number" then
				return tonumber(s.x)
			elseif s._____serialized == "Instance" then
				local i = Instance.new(self:Unserialize(s.x.ClassName))
				for _,v in pairs(s.x) do
					pcall(function() i[_] = self:Unserialize(v) end)
				end
				
				for _,v in pairs(x.c) do
					local c = self:Unserialize(v)
					c.Parent = i
				end
				
				return i
			elseif s._____serialized == "Enum" then
			
			elseif s._____serialized == "BrickColor" then
			
			end
		end
	end
}}