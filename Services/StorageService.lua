-- For storing and fetching serialized data to/from the webserver.


return {"StorageService", "StorageService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Requests = 0,
	Get = function(self)
	
	end,
	Set = function(self)
	
	end,
	Delete = function(self)
	
	end,
	Update = function(self)
	
	end
}}