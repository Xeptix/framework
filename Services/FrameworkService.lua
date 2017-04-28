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
		
		print("[ Framework *D ]", ...)--
	end, 
	CheckArgument = function(self, stack, func, arg, got, expecting)
		local t = typeof(got):lower()
		
		if typeof(expecting) == "table" then
			local goodToGo = false 
			
			for _,v in pairs(expecting) do
				if t == v:lower() then
					goodToGo = true
					break
				end
			end
			
			if not goodToGo then
				ferror(stack, "bad argument #" .. arg .. " to '" .. (func or "?") .. "' (" .. table.join(expecting, ",", "or") .. " expected, got " .. t .. ")", 0)
			end
		else -- NOTE: if you got an error here, it is NOT a framework error. Ignore all lines in the stack trace that go to the framework's scripts. Typically the very bottom script(s) are the ones where the actual error was triggered. More info on this in documentation.
			if t ~= expecting:lower() then
				ferror(stack, "bad argument #" .. arg .. " to '" .. (func or "?") .. "' (" .. expecting .. " expected, got " .. t .. ")", 0)
			end
		end
	end,
	LockServer = function(self, stack, name)
		if not game:Is("Server") then
			ferror(stack, name .. " must be ran on the server.")
		end
	end,
	LockClient = function(self, stack, name)
		if not game:Is("Client") then
			ferror(stack, name .. " must be ran on the client.")
		end
	end,
	LockConnected = function(self, stack, name)
		if not game:Is("Connected") and false then
			ferror(stack, name .. " requires your game to be connected to the framework's webservers. Open your game in Studio and use the Xeptix Framework Plugin to connect your game!")
		end
	end,
	Serialize = function(self, x, o)
		local s = {}
		
		if typeof(x) == "Instance" then
			s._____serialized = "Instance"
			s.x = {}
			for i,v in pairs(x:GetProperties()) do
				if i ~= "Parent" then
					s.x[i] = self:Serialize(v)
				end
			end
			
			s.c = {}
			for _,v in pairs(x:GetChildren()) do
				table.insert(s.c, self:Serialize(v))
			end
		elseif typeof(x) == "table" then
			s._____serialized = "table"
			local n = {}
			for _,v in pairs(x) do
				n[self:Serialize(_)] = self:Serialize(v)
			end
			s.x = n
		else
			s._____serialized = typeof(x)
			s.x = tostring(x)
		end
		
		return o and s or game.HttpService:JSONEncode(s)
	end,
	Unserialize = function(self, x)
		local s = x
		pcall(function()
			s = game.HttpService:JSONDecode(x)
		end)
		
		if s and typeof(s) == "table" and s._____serialized and s.x then
			if s._____serialized == "string" then
				return s.x
			elseif s._____serialized == "number" then
				return tonumber(s.x)
			elseif s._____serialized == "table" then
				local n = {}
				for _,v in pairs(s.x) do
					n[self:Unserialize(_)] = self:Unserialize(v)
				end
				
				return n
			elseif s._____serialized == "Instance" then
				local i
				pcall(function() i = Instance.new(self:Unserialize(s.x.ClassName)) end)
				
				if i then
					for _,v in pairs(s.x) do
						pcall(function() print(_, typeof(self:Unserialize(v))) end)
						pcall(function() i[_] = self:Unserialize(v) end)
					end
					
					for _,v in pairs(s.c) do
						local c = self:Unserialize(v)
						if c then
							c.Parent = i
						end
					end
				end
				
				return i
			elseif s._____serialized == "boolean" then
				return s.x == "true"
			elseif s._____serialized == "Enums" then
				return Enum
			elseif s._____serialized == "Enum" then
				return Enum[s.x]
			elseif s._____serialized == "EnumItem" then
				local x = string.split(s.x,".")
				return Enum[x[2]][x[3]]
			elseif s._____serialized == "BrickColor" then
				return BrickColor.new(s.x)
			elseif s._____serialized == "Ray" then
				local x = string.split(s.x, "},")
				return Ray.new(Vector3.new(string.split(x[1]:gsub(" ",""):gsub("{", ""):gsub("}", ""),",")), Vector3.new(string.split(x[2]:gsub(" ",""):gsub("{", ""):gsub("}", ""),",")))
			elseif s._____serialized == "UDim2" then
				return UDim2.new(string.split(s.x:gsub(" ",""):gsub("{", ""):gsub("}", ""),","))
			elseif s._____serialized == "Region3int16" or s._____serialized == "Region3" or s._____serialized == "UDim" or s._____serialized == "Vector3" or s._____serialized == "Vector2" or s._____serialized == "CFrame" or s._____serialized == "Color3" then
				return getfenv()[s._____serialized].new(string.split(s.x:gsub(" ",""),","))
			end
		end
	end
}}