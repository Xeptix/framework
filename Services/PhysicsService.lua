-- PhysicsService Additions

return {"PhysicsService", "PhysicsService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	GetColliding = function(self, Object, IgnoreList)
	   game.FrameworkService:CheckArgument(debug.traceback(), "GetColliding", 1, {"Instance"}, "Object")
		game.FrameworkService:CheckArgument(debug.traceback(), "GetColliding", 2, {"table", "nil"}, "Object")
		
		if not Object:IsA("Model") and not Object:IsA("BasePart") and not Object:IsA("GuiObject") then
			warn("GetColliding Arg #1 must be a Model, Part, or GUI!")
			return {}
		end
		
		if type(IgnoreList) ~= "table" then
			IgnoreList = {Object}
		else
			table.insert(IgnoreList, Object)
		end
	
		if Object:IsA("GuiObject") then
			-- Get all of the GuiObjects (Frames, buttons, labels, images, etc)
			local Parent = Object
			repeat
				Parent = Parent.Parent
			until Parent:IsA("ScreenGui") or Parent:IsA("SurfaceGui") or Parent:IsA("BillboardGui") or Parent == game
			
			if Parent ~= game then
				Parent = Parent.Parent
			end
	
	
			local GuiObjects = {}
			Parent:Recursive(function(o)
				if o:IsA("GuiObject") and o ~= Object and not table.exists(IgnoreList, o) then
					table.insert(GuiObjects, o)
				end
			end)
	
			
			-- Collision checking
			local Colliding = {}
	
			for _,v in pairs(GuiObjects) do
				local gui1, gui2 = Object, v
				local C = ((gui1.AbsolutePosition.X < gui2.AbsolutePosition.X + gui2.AbsoluteSize.X and gui1.AbsolutePosition.X + gui1.AbsoluteSize.X > gui2.AbsolutePosition.X) and (gui1.AbsolutePosition.Y > gui2.AbsolutePosition.Y and gui1.AbsolutePosition.Y < gui2.AbsolutePosition.Y + gui2.AbsoluteSize.Y)) or ((gui2.AbsolutePosition.X < gui1.AbsolutePosition.X + gui1.AbsoluteSize.X and gui2.AbsolutePosition.X + gui2.AbsoluteSize.X > gui1.AbsolutePosition.X) and (gui2.AbsolutePosition.Y > gui1.AbsolutePosition.Y and gui2.AbsolutePosition.Y < gui1.AbsolutePosition.Y + gui1.AbsoluteSize.y))
	
				if C then
					table.inset(Colliding, v)
				end
			end
	
			return Colliding
		end
	
		local CF = self:GetCFrame(Object)
		local Size
		if Object:IsA("Model") then
			Size = Object:GetModelSize()
		else
			Size = Object.Size
		end
	
		local Part = Instance.new("Part", workspace)
		Part.Anchored = true
		Part.CanCollide = true
		Part.Transparency = 1
		--Part.FormFactor = "Custom"
		Part.Size = Size
		Part.CFrame = CF
	
		local Colliding, RealColliding = Part:GetTouchingParts(), {}
		Part:Destroy()
	
		for _,v in pairs(Colliding) do
			if not table.exists(IgnoreList, v) then
				table.insert(RealColliding, v)
			end
		end
	
		return RealColliding
	end,
	IsColliding = function(self, Object, SecondObject, IgnoreList)
		game.FrameworkService:CheckArgument(debug.traceback(), "IsColliding", 1, Object, {"Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "IsColliding", 2, SecondObject, {"Instance"})
		game.FrameworkService:CheckArgument(debug.traceback(), "IsColliding", 3, IgnoreList, {"table", "nil"})
		
		if not Object:IsA("Model") and not Object:IsA("BasePart") and not Object:IsA("GuiObject") then
			warn("IsColliding Arg #1 must be a Model, Part, or GUI!")
			return false
		end
		
		if not Object:IsA("Model") and not Object:IsA("BasePart") and not Object:IsA("GuiObject") then
			warn("IsColliding Arg #2 must be a Model, Part, or GUI!")
			return false
		end
	
		local Colliding = self:GetColliding(Object, IgnoreList)
	
		for _,v in pairs(Colliding) do
			if v == SecondObject or (not v:IsA("GuiObject") and v:IsDescendantOf(SecondObject)) then
				return true
			end
		end
	
		return false
	end
}}