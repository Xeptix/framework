-- Core Job!

return function(a, b, c, d, e, f, g, h, i, j, k, l)
	game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

	local FrameworkService = game:GetService("FrameworkService")
	FrameworkService.debugMode = true -- temporary
	local ThreadService = game:GetService("ThreadService")
	local FrameworkInternalService = game:GetService("FrameworkInternalService")
	local FrameworkHttpService = game:GetService("FrameworkHttpService")
	local FrameworkModule = game:GetFrameworkModule()
	
	game:SetProperty("Info", "")
	game:LockProperty("Name", 2)
	
	if FrameworkModule.WebConnection.Connection.Value and FrameworkHttpService.HttpEnabled then
		local WebConnection = {}
		for _,v in pairs(FrameworkModule.WebConnection:GetChildren()) do
			WebConnection[v.Name] = v.Value
		end
		
		FrameworkHttpService:SetProperty("WebConnection", WebConnection)
	end
	
	FrameworkService:Output("Loaded successfully! " .. game.Info)
	
	return FrameworkService
end