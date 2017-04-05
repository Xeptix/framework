-- An example of a service!

return {"FrameworkInternalService", "FrameworkInternalService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		self:SetProperty("ServerId", 0)
		self:SetProperty("ServerInfo", false)
		
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	GatherIdentifyableInformation = function(self)
		return self.ServerId .. "[" .. (game.JobId or "0") .. "]" .. (game.CreatorId or "0") .. "[" .. tostring(game.CreatorType) .. "]" .. (game.VIPServerId or 0) .. "[" .. (game.VIPServerOwnerId or 0) .. "]"
	end,
	Report = function(self, message)
		game:GetService("FrameworkHttpService"):Post("%url/report", {message = message})
		game:GetService("FrameworkService"):DebugOutput("Report sent: " .. message)
	end
}}
