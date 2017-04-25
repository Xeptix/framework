-- An internal service which handles player's data.

return {"PlayerDataService", "PlayerDataService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	LoadData = function(self, player, profile)
	
	end,
	SaveData = function(self, player, profile)
	
	end,
	DeleteData = function(self, player, profile)
	
	end,
	CopyData = function(self, player, profile1, profile2)
	
	end,
	WaitForData = function(self, player, profile)
	
	end,
}}