-- An example of a service!

local Tasks = {}
return {"ThreadService", "ThreadService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		local db
		local function manager()
			if #Tasks > 0 and not db then
				db = true
				
				local Task = table.remove(Tasks, 1)
				if typeof(Task) == "function" then
					db = false
					return Task()
				elseif typeof(Task) == "table" then
					
				end
				
				db = false
			end
		end
		
		if game:Is("Local") then
			game:GetService("RunService").Hearbeat:connect(manager)
		else
			game:GetService("RunService").Stepped:connect(manager)
		end
		
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Run = function(self, func)
		table.insert(Tasks, func)
	end,
}}