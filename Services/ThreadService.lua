-- Mostly internal for now. We should really clean this up sometime lol.
-- Kinda cleaned up? Meh, good enough! Ready for documentation.

local Tasks = {}
local StopRunOnClose = {}
return {"ThreadService", "ThreadService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		local t = os.time()
		local function process()
			local Task = table.remove(Tasks, 1)
			if typeof(Task) == "function" then
				pcall(Task)
			elseif typeof(Task) == "table" then
				if Task.next and Task.next >= t and not Task.stop then
					table.insert(Tasks, Task)
				elseif not Task.stop then
					local function requeue()
						if Task.db > 1/30 then
							Task.next = t + Task.db
							table.insert(Tasks, Task)
						else
							table.insert(Tasks, Task)
						end--
					end
					
					if Task.yield then
						pcall(Task.task)
						requeue()
					else
						requeue()
						pcall(Task.task)
					end
				end
			end--
		end--
		game:GetService("RunService").Stepped:connect(function(_, x)
			t = t + x
			
			local nt = #Tasks -- n't (shoutout to cody ko!)
			if nt > 0 then
				for i = 0, nt / 30 do -- we want to efficiently handle over 30 tasks at onces
					process() -- should we be concerned about this delaying?... nah!
				end -- maybe eventually we'll make a new Stepped connection for every 30 tasks?
			end
		end)
		
		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Run = function(self, func)
		game.FrameworkService:CheckArgument(debug.traceback(), "Run", 1, func, "function")
		
		table.insert(Tasks, func)
	end,
	threads = {},
	nextid = 0,
	Thread = function(self, func, opt)
		game.FrameworkService:CheckArgument(debug.traceback(), "Thread", 1, func, "function")
		game.FrameworkService:CheckArgument(debug.traceback(), "Thread", 2, opt, {"table", "nil"})
		
		if not opt then opt = {} else
			for _,v in pairs(opt) do
				opt[_:lower()] = v
			end
		end
		
		local id = self.nextid + 1
		self.nextid = id
		
		table.insert(Tasks, {
			id = id,
			task = func,
			db = tonumber(opt.delay) or 0,
			yield = opt.yield == nil or opt.yield == true,
			onclose = opt.onclose == true,
			runnow = opt.runnow == true
		})
		
		if opt.onclose == true then
			game:BindToClose(function()
				if StopRunOnClose[id] then return end
				
				pcall(func)
			end)
		end
		
		if opt.runnow then
			spawn(func)
		end
		
		local rekt
		return function()
			if rekt then return true end
			
			for i = 1,100 do -- we'll find a better way to go about this sumdai
				for _,v in pairs(Tasks) do
					if typeof(v) == "table" and v.id == id then
						if Tasks[_].onclose then StopRunOnClose[id] = true end
						
						Tasks[_].stop = true
						rekt = true
						return true
					end
				end
				
				wait(.1)
			end
		end
	end
}}