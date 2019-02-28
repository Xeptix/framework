-- Core framework service.

local argumentCheckingEnabled = true
local Legacy
return {"FrameworkService", "FrameworkService", {
	Version = "3.2", -- t is for testing
	Build = 550,
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l, m)
		otypeof = typeof
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require, ferror = a, b, c, d, e, f, g, h, i, j, k, l, m

		self:LockProperty("Version", 2)--
		self:LockProperty("Build", 2)

		self:DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Output = function(self, ...)
		if not self.outputEnabled then return end

		print("[ Framework ]", ...)
	end,
	outputEnabled = false,
	debugMode = false, -- outputs debug stuff to console
	DebugOutput = function(self, ...)
		local a,s = {...},""
		for _,v in pairs(a) do
			local e = s == "" and "" or "_%%%SPACE%%%_"

			s = e .. tostring(v)
		end

		if game:IsFrameworkServiceLoaded("FrameworkHttpService") then
			--todo
		end

		if not self.debugMode then return end

		print("[ Framework *D ]", ...)--
	end,
	DisableArgumentChecking = function(self)
		argumentCheckingEnabled = false
	end,
	CheckArgument = function(self, stack, func, arg, got, expecting)
		if argumentCheckingEnabled == false then return end

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
		else -- Notice: if you got an error here, it is NOT a framework error. Ignore all lines in the stack trace that go to the framework's scripts. Typically the very bottom script(s) are the ones where the actual error was triggered. More info on this in the documentation on our website.
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
			ferror(stack, name .. " must be ran on a client.")
		end
	end,
	LockConnected = function(self, stack, name)
		if not game:Is("Connected") and false then
			ferror(stack, name .. " requires your game to be connected to the framework's webservers. Open your game in Studio and use the Xeptix Framework Plugin to connect your game!")
		end
	end,
	LightSerialize = function(self, x, o, isk)
		local s = {}

		local tox = typeof(x)
		if tox == "Instance" then
			s._____serialized = "Instance"
			s.x = {}
			for i,v in pairs(x:GetProperties()) do
				if i ~= "Parent" then
					s.x[i] = self:LightSerialize(v)
				end
			end

			s.c = {}
			for _,v in pairs(x:GetChildren()) do
				table.insert(s.c, self:LightSerialize(v))
			end
		elseif tox == "table" then
			s._____serialized = "table"
			local n = {}
			for _,v in pairs(x) do
				n[self:LightSerialize(_, nil, true)] = self:LightSerialize(v)--
			end
			s.x = n
		elseif tox == "string" then
			return x
		elseif not isk and tox == "number" then
			return x
		elseif not isk and  tox == "boolean" then
			return x
		else
			s._____serialized = tox
			s.x = tostring(x)
		end

		return o and s or game.HttpService:JSONEncode(s)
	end,
	LightUnserialize = function(self, x)
		return self:Unserialize(x)
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
				n[self:Serialize(_)] = self:Serialize(v)--
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
				return Ray.new(Vector3.new(unpack(string.split(x[1]:gsub(" ",""):gsub("{", ""):gsub("}", ""),","))), Vector3.new(unpack(string.split(x[2]:gsub(" ",""):gsub("{", ""):gsub("}", ""),","))))
			elseif s._____serialized == "Region3" then
				local x = string.split(s.x, ";")
				local pos = CFrame.new(unpack(string.split(x[1]:gsub(" ",""):gsub("{", ""):gsub("}", ""),","))).p
				local sz = Vector3.new(unpack(string.split(x[2]:gsub(" ",""):gsub("{", ""):gsub("}", ""),",")))

				local SizeOffset = sz/2
				local Point1 = pos - SizeOffset
				local Point2 = pos + SizeOffset
				return Region3.new(Point1, Point2)
			elseif s._____serialized == "Region3int16" then
				local x = string.split(s.x, ";")
				local a = CFrame.new(unpack(string.split(x[1]:gsub(" ",""):gsub("{", ""):gsub("}", ""),","))).p
				local pos = Vector3int16.new(a.x,a.y,a.z)
				local sz = Vector3int16.new(unpack(string.split(x[2]:gsub(" ",""):gsub("{", ""):gsub("}", ""),",")))

				local SizeOffset = sz/2
				local Point1 = pos - SizeOffset
				local Point2 = pos + SizeOffset
				return Region3int16.new(Point1, Point2)
			elseif s._____serialized == "UDim2" then
				return UDim2.new(unpack(string.split(s.x:gsub(" ",""):gsub("{", ""):gsub("}", ""),",")))
			elseif s._____serialized == "Region3int16" or s._____serialized == "Vector3int16" or s._____serialized == "Vector2int16" or s._____serialized == "Region3" or s._____serialized == "UDim" or s._____serialized == "Vector3" or s._____serialized == "Vector2" or s._____serialized == "CFrame" or s._____serialized == "Color3" then
				return getfenv()[s._____serialized].new(unpack(string.split(s.x:gsub(" ",""),",")))
			end
		elseif typeof(x) == "table" then
			local n = {}
			for _,v in pairs(x) do
				n[self:Unserialize(_)] = self:Unserialize(v)
			end

			return n
		end

		return x
	end,
	ShutdownServer = function(self, msg)
		game.FrameworkService:CheckArgument(debug.traceback(), "ShutdownServer", 1, msg, {"string", "nil"})

		game.Players:KickAll(msg)
		game.Players.PlayerAdded:connect(function(Plr)
			Plr:Kick(msg)
		end)
	end,
	-- Notice: The method below (GetLegacyFrameworkObject) is not guarenteed to function properly, and it is not advised to use it. This is only to allow v1/v2 places to operate with the new framework without (very much) code changes.
	GetLegacyFrameworkObject = function(self) --todo: returns a legacy object equivilent to the "_G.framework"/"framework" variables from v1/v2, so that way people can just throw in "framework = game.FrameworkService:GetLegacyFrameworkObject()" for support without altering code.
		if Legacy then return Legacy end

		LegacyObj = {}

		Legacy = setmetatable(Legacy, {})-- do we need this anymore?
		return Legacy
	end
}}
