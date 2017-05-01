-- Core Job!

return function(a, b, c, d, e, f, g, h, i, j, k, l)
	game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

	local FrameworkService = game:GetService("FrameworkService")
	FrameworkService.debugMode = true -- temporary
	local ThreadService = game:GetService("ThreadService")
	local FrameworkInternalService = game:GetService("FrameworkInternalService")
	local FrameworkHttpService = game:GetService("FrameworkHttpService")
	local FrameworkModule = game:GetFrameworkModule()
	
	--game:SetProperty("Info", "")
	game:LockProperty("Name", 2)
	
	if FrameworkHttpService.PayloadEnabled and game:Is("Server") then -- Payload Stuff!
		game.Players.PlayerAdded:connect(function(Player)
			FrameworkHttpService.payload.players[tostring(Player.userId)] = {
				userid = Player.userId,
				username = Player.Name,
				joined = os.time(),
				age = Player.AccountAge,
				follow = Player.FollowUserId,
				bc = string.split(tostring(Player.MembershipType), ".")[3]
			}
		end)
		
		game.Players.PlayerRemoving:connect(function(Player)
			if not FrameworkHttpService.payload.players[tostring(Player.userId)] then wait(1) end
			
			if FrameworkHttpService.payload.players[tostring(Player.userId)] then
				local plr = FrameworkHttpService.payload.players[tostring(Player.userId)]
				FrameworkHttpService.payload.players[tostring(Player.userId)] = nil
				
				plr.left = os.time()
				plr.time = plr.left - plr.joined
				table.insert(FrameworkHttpService.payload.visits, plr)
			end
		end)
		
		
		local LastError = nil
		local Stack = {}
		game:GetService("LogService").MessageOut:connect(function(message, messagetype)
			--print("Eh",message,messagetype)
			if messagetype == Enum.MessageType.MessageInfo and message == "Stack End" then
				table.insert(Stack, message)
				
				table.insert(FrameworkHttpService.payload.errors, {
					message = LastError,
					stack = Stack,
					time = os.time()
				})
				
				Stack, LastError = {}, nil
			elseif messagetype == Enum.MessageType.MessageError then
				LastError = message;
			elseif LastError and messagetype == Enum.MessageType.MessageInfo then
				table.insert(Stack, message)
			end
		end)

		if game:GetFrameworkModule():findFirstChild"ClientErrorReporting" then
			game:GetFrameworkModule()["ClientErrorReporting"]:Destroy()
		end
		
		local CER = Instance.new("RemoteEvent")
		CER.Name = "ClientErrorReporting"
		CER.OnServerEvent:connect(function(Player, Err)
			if type(Err) == "table" and Err.message and Err.stack and Err.time then
				Err.userid = Player.userId
				Err.username = Player.Name
				
				table.insert(FrameworkHttpService.payload.errors, Err)
			end
		end)
		CER.Parent = game:GetFrameworkModule()
	else
		local LastError = nil
		local Stack = {}
		local Module = game:GetFrameworkModule()
		local con
		con = game:GetService("LogService").MessageOut:connect(function(message, messagetype)
			if messagetype == Enum.MessageType.MessageInfo and message == "Stack End" then
				table.insert(Stack, message)
				
				local x = Module:WaitForChild("ClientErrorReporting", 60)
				if not x then return con:disconnect() end
				
				Module.ClientErrorReporting:FireServer({
					message = LastError,
					stack = Stack,
					time = os.time()
				})
				
				Stack, LastError = {}, nil
			elseif messagetype == Enum.MessageType.MessageError then
				LastError = message;
			elseif LastError and messagetype == Enum.MessageType.MessageInfo then
				table.insert(Stack, message)
			end
		end)
	end
	
	if game:Is("Server") and FrameworkModule.WebConnection.Connection.Value and FrameworkHttpService.HttpEnabled then
		local WebConnection = {}
		for _,v in pairs(FrameworkModule.WebConnection:GetChildren()) do
			WebConnection[v.Name] = v.Value
		end
		
		FrameworkHttpService:SetProperty("WebConnection", WebConnection)
		FrameworkHttpService:LockProperty("WebConnection", 2)
		
		-- Payloads
		if FrameworkHttpService.PayloadEnabled then
			local LastSuccessfulPayload = os.time()
			ThreadService:Thread(function()
				if LastSuccessfulPayload + 300 <= os.time() then
					FrameworkHttpService:ClearPayload()
				end
			end, 60, true)
			
			ThreadService:Thread(function()
				local res = FrameworkHttpService:Post("payload", FrameworkHttpService:GetPayload(), {json=true})
				
				if res and res.success then
					LastSuccessfulPayload = os.time()
					FrameworkHttpService:ClearPayload()
				end
			end, FrameworkHttpService.PayloadDelay, true)
			
			game:BindToClose(function() LastSuccessfulPayload = os.time() FrameworkHttpService:Post("payload", FrameworkHttpService:GetPayload(), {json=true}) end)
		end
	end
	
	FrameworkService:Output("Loaded successfully! " .. game.Info)
	
	return FrameworkService
end