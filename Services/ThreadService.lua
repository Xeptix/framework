-- An example of a service!

local Tasks = {}
return {"ThreadService", "ThreadService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		local function manager() 
			if #Tasks > 0 then
				local Task = table.remove(Tasks, 1)
				if typeof(Task) == "function" then
					return Task()
				elseif typeof(Task) == "table" then
					if not Task.stop then
						if Task.yield then
							Task.task()
						else
							spawn(Task.task)
						end
						
						if Task.db > 1/30 then
							delay(Task.db, function() table.insert(Tasks, Task) end)
						else
							table.insert(Tasks, Task)
						end
					end
				end
			end
		end
		
		spawn(function()
			while wait() do
				pcall(manager)
			end
		end)
		
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Run = function(self, func)
		table.insert(Tasks, func)
	end,
	threads = {},
	nextid = 0,
	Thread = function(self, func, db, noyield)
		local id = self.nextid + 1
		self.nextid = self.nextid + 1
		
		table.insert(Tasks, {
			id = id,
			task = func,
			db = tonumber(db) or 0,
			yield = not noyield
		})
		
		return function()
			for _,v in pairs(Tasks) do
				if typeof(v) == "table" and v.id == id then
					Tasks[_].stop = true
				end
			end
		end
	end
}}