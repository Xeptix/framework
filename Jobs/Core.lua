-- Core Job!

return function(a, b, c, d, e, f, g, h, i, j, k, l)
	game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

	local FrameworkService = game:GetService("FrameworkService")
	local FrameworkInternalService = game:GetService("FrameworkInternalService")
	local FrameworkHttpService = game:GetService("FrameworkHttpService")
	local ThreadService = game:GetService("ThreadService")
	local FrameworkModule = game:GetFrameworkModule()
	
	game:SetProperty("Info", "")
	game:LockProperty("Name", 2)
	
	if FrameworkModule.WebConnection.Connection.Value and FrameworkHttpService.HttpEnabled then
		ThreadService:Run(function()
			game.ServerInfo = ""
		end)
		
		FrameworkInternalService:Report("Server " .. game.Info .. " is connected to the website and ready to make requests!")
	end
	
	FrameworkService:Output("Loaded successfully! " .. game.Info)
end
