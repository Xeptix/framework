-- An example of a service!

return {"FrameworkInternalService", "FrameworkInternalService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		self:SetProperty("ServerId", 0)
		self:SetProperty("ServerInfo", self:GatherIdentifyableInformation())
		
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	GatherIdentifyableInformation = function(self)
		return (game.PlaceId or "0") .. "; " .. self.ServerId .. "[" .. (game.JobId or "0") .. "]" .. (game.CreatorId or "0") .. "[" .. tostring(game.CreatorType) .. "]" .. (game.VIPServerId or 0) .. "[" .. (game.VIPServerOwnerId or 0) .. "]"
	end,
	Report = function(self, message)
		game:GetService("FrameworkHttpService"):Post("report", {message = message}, {})
		game:GetService("FrameworkService"):DebugOutput("Report sent: " .. message)
	end, 
	Snowflake = function(self)--
		local flake = game:GetService("FrameworkHttpService"):Get("snowflake") 
		
		return flake
	end,
	Var2Val = function(self, Var)
		local t = typeof(Var)
		local val, f
		if t == "string" then
			val = "StringValue"
		elseif t == "number" then
			val = "NumberValue"
		elseif t == "boolean" then
			val = "BoolValue"
		else
			val, f = "StringValue", function(v)
				Instance.new("Folder", v).Name = "Serialized"
				v:SetProperty("SerializedValue", true)
				v.Value = game.FrameworkService:Serialize(Var)
			end
		end
		
		local v = Instance.new(val)
		if f then f(v) else v.Value = Var end
		
		return v
	end,
	Val2Var = function(self, Val)
		if Val:findFirstChild("Serialized") then
			return game.FrameworkService:Unserialize(Val.Value)
		else
			return Val.Value
		end
	end,
	UpdateVal = function(self, Val, Var)
		local heh = {}
		heh.string = true;
		heh.number = true;
		heh.boolean = true;
		
		local new
		if Val:findFirstChild("Serialized") and heh[typeof(Var)] then
			new = self:Var2Val(Var)
		elseif Val:findFirstChild"Serialized" then
			Val.Value = game.FrameworkService:Serialize(Var)
		elseif typeof(Var) ~= typeof(Val.Value) then
			new = self:Var2Val(Var)
		else
			Val.Value = Var
		end
		
		if new and Val.Parent then
			new.Name = Val.Name
			local p = Val.Parent
			Val:Destroy()
			new.Parent = p
		end
	end
}}