-- An example of a service!

return {"ThreadService", "ThreadService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end
}}