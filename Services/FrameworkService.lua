-- Core framework service.

return {"FrameworkService", "FrameworkService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l, m)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require, ferror = a, b, c, d, e, f, g, h, i, j, k, l, m

		self:DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Output = function(self, ...)
		print("[ Framework ]", ...)
	end,
	debugMode = false,
	DebugOutput = function(self, ...)
		if not self.debugMode then return end
		
		print("[ Framework *D ]", ...)
	end,
	CheckArgument = function(self, stack, func, arg, got, expecting)
		local t = typeof(got)
		
		if typeof(expecting) == "table" then
			local goodToGo = false
			
			for _,v in pairs(expecting) do
				if t == v then
					goodToGo = true
					break
				end
			end
			
			if not goodToGo then
				ferror(stack, "bad argument #" .. arg .. " to '" .. (func or "?") .. "' (" .. table.join(expecting, ",", "or") .. " expected, got " .. t .. ")", 0)
			end
		else -- NOTE: if you got an error here, it is NOT a framework error. Ignore all lines in the stack trace that go to the framework's scripts. Typically the very bottom script(s) are the ones where the actual error was triggered. More info on this in documentation.
			if t ~= expecting then
				ferror(stack, "bad argument #" .. arg .. " to '" .. (func or "?") .. "' (" .. expecting .. " expected, got " .. t .. ")", 0)
			end
		end
	end
}}