-- An example of a service!

local AutosizeCanvases = {}
return {"GuiService", "GuiService", {
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	AutosizeCanvas = function(self, ScrollingFrame, paddingOverride)
		game.FrameworkService:CheckArgument(debug.traceback(), "AutosizeCanvas", 1, ScrollingFrame, "Instance")
		
		if not ScrollingFrame:IsA("ScrollingFrame") then return error("GuiService:AutosizeCanvas() #1 Arg. Must be a scrolling frame!") end

		if AutosizeCanvases[ScrollingFrame] then return end
		AutosizeCanvases[ScrollingFrame] = true
		local _c = {}
		table.insert(_c, ScrollingFrame.Changed:connect(function(Prop)
			if Prop == "Parent" and not ScrollingFrame.Parent then
				AutosizeCanvases[ScrollingFrame] = nil
			elseif Prop == "Parent" and ScrollingFrame.Parent and not AutosizeCanvases[ScrollingFrame] then
				AutosizeCanvases[ScrollingFrame] = ScrollingFrame
			end
		end))
		
		local padding = 0
		
		if not paddingOverride then
			paddingOverride = padding
		end
		
		local nextUpdate, alreadyUpdatingAgain, updateDelay = 0, false, 0.5
		local function UpdateSize()
			if nextUpdate >= tick() then -- HUGE lag fix ;)
				if not alreadyUpdatingAgain then
					alreadyUpdatingAgain = true
					delay(nextUpdate-tick()+(1/30), UpdateSize)
				end
				
				return
			end
			
			--print("UPDATING GUI!")
			alreadyUpdatingAgain = false
			nextUpdate = tick() + updateDelay
			
			local CanvasSizeX, CanvasSizeY = 0, 0
			
			local Recursive = function(Parent)
				for _,v in pairs(Parent:GetChildren())do
					--Recursive(v)
	
					if v:IsA("GuiObject") then
						local BottomPosition, RightPosition = 
							((v.Position.Y.Scale * v.Parent.AbsoluteSize.Y) + v.Position.Y.Offset) + 
							((v.Size.Y.Scale * v.Parent.AbsoluteSize.Y) + v.Size.Y.Offset),
							((v.Position.X.Scale * v.Parent.AbsoluteSize.X) + v.Position.X.Offset) +
							((v.Size.X.Scale * v.Parent.AbsoluteSize.X) + v.Size.X.Offset)
							
						if BottomPosition > CanvasSizeY then
							CanvasSizeY = BottomPosition
						end
						
						if RightPosition > CanvasSizeX then
							CanvasSizeX = RightPosition
						end
					end
				end
			end
			
			
			local ORecursive
			if ScrollingFrame:FindFirstChildOfClass("UIGridLayout") then
				local Grid = ScrollingFrame:FindFirstChildOfClass("UIGridLayout")
				if Grid.FillDirection == Enum.FillDirection.Horizontal and Grid.HorizontalAlignment == Enum.HorizontalAlignment.Left and Grid.StartCorner == Enum.StartCorner.TopLeft and Grid.VerticalAlignment == Enum.VerticalAlignment.Top then
					ORecursive = Recursive
					Recursive = function(Parent)
						local Objects = #ScrollingFrame:GetChildren() - 1
						local X, Y = 0, 0
						
						local CellSizeX, CellSizeY =
							Grid.CellSize.X.Offset + (Grid.CellSize.X.Scale * ScrollingFrame.AbsoluteSize.X) + (Grid.CellPadding.X.Offset + (Grid.CellPadding.X.Scale * ScrollingFrame.AbsoluteSize.X)),
							Grid.CellSize.Y.Offset + (Grid.CellSize.Y.Scale * ScrollingFrame.AbsoluteSize.Y) + (Grid.CellPadding.Y.Offset + (Grid.CellPadding.Y.Scale * ScrollingFrame.AbsoluteSize.Y))
					
						
						local MaxSizeX = ScrollingFrame.AbsoluteSize.X
						local MaxSizeY = ScrollingFrame.AbsoluteSize.Y
						
						CanvasSizeX = CellSizeX * Objects
						if CanvasSizeX > MaxSizeX then CanvasSizeX = MaxSizeX end
						CanvasSizeY = math.ceil((CellSizeX * Objects) / MaxSizeX) * CellSizeY
					end
				elseif Grid.FillDirection == Enum.FillDirection.Vertical and Grid.HorizontalAlignment == Enum.HorizontalAlignment.Left and Grid.StartCorner == Enum.StartCorner.TopLeft and Grid.VerticalAlignment == Enum.VerticalAlignment.Top then
					ORecursive = Recursive
					Recursive = function(Parent)
						local Objects = #ScrollingFrame:GetChildren() - 1
						local X, Y = 0, 0
						
						local CellSizeX, CellSizeY =
							Grid.CellSize.X.Offset + (Grid.CellSize.X.Scale * ScrollingFrame.AbsoluteSize.X) + (Grid.CellPadding.X.Offset + (Grid.CellPadding.X.Scale * ScrollingFrame.AbsoluteSize.X)),
							Grid.CellSize.Y.Offset + (Grid.CellSize.Y.Scale * ScrollingFrame.AbsoluteSize.Y) + (Grid.CellPadding.Y.Offset + (Grid.CellPadding.Y.Scale * ScrollingFrame.AbsoluteSize.Y))
					
						local MaxSizeY = ScrollingFrame.AbsoluteSize.Y
						local MaxY, tY = 0, 0
						
						for i = 1,Objects do
							if Y + CellSizeY <= MaxSizeY or Y == 0 then
								Y = Y + CellSizeX
							elseif MaxY == 0 then
								MaxY = Y
							end
						end
						
						for i = 1,Objects do
							tY = tY + CellSizeY
							if tY >= MaxY then
								tY = 0
								X = X + CellSizeX
							end
						end
					
						CanvasSizeY, CanvasSizeX = Y, X
					end
				end 
				
				--CanvasSizeY, CanvasSizeX = ScrollingFrame.AbsoluteSize.Y, ScrollingFrame.AbsoluteSize.X
			end
	
			local CanvasPosition = ScrollingFrame.CanvasPosition
			ScrollingFrame.CanvasSize = UDim2.new()
			
			Recursive(ScrollingFrame)
			local a,b = CanvasSizeX, CanvasSizeY
			if ORecursive and false then
				ORecursive(ScrollingFrame)
				if a > CanvasSizeX then
					CanvasSizeX = a
				end
				if b > CanvasSizeY then
					CanvasSizeY = b
				end
			end
			
			
			ScrollingFrame.CanvasSize = UDim2.new(0, CanvasSizeX + paddingOverride, 0, CanvasSizeY + paddingOverride)
			ScrollingFrame.CanvasPosition = CanvasPosition
		end
		
		table.insert(_c, ScrollingFrame.ChildAdded:connect(function(Child)
			if Child:IsA("GuiObject") then
				UpdateSize()
				
				Child.Changed:connect(function(prop)
					if prop == "Position" or prop == "Size" then
						UpdateSize()
					end
				end)
			end
		end))
		table.insert(_c, ScrollingFrame.ChildRemoved:connect(function(Child)
			if Child:IsA("GuiObject") then
				UpdateSize()
			end
		end))
		
		table.insert(_c, ScrollingFrame.Changed:connect(function(prop)
			if prop == "Position" or prop == "Size" then -- we dont want to spam this every time you scroll
				UpdateSize()
			end
		end))
		
		UpdateSize()
		
		local quit
		return function()
			if quit then return end quit = true
			for _,v in pairs(_c) do
				v:disconnect()
			end
			AutosizeCanvases[ScrollingFrame] = nil
			_c = nil
		end
	end
}}