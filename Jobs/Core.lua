-- Core Job!

return function(a, b, c, d, e, f, g, h, i, j, k, l)
	game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

	local FrameworkService = game:GetService("FrameworkService")
	local ThreadService = game:GetService("ThreadService")
	local FrameworkInternalService = game:GetService("FrameworkInternalService")
	local FrameworkHttpService = game:GetService("FrameworkHttpService")
	local FrameworkModule = game:GetFrameworkModule()
	
	--game:SetProperty("Info", "")
	game:LockProperty("Name", 2)
	
	
	if FrameworkModule.WebConnection.Connection.Value and game:Is("Server") then -- Payload Stuff!
		game.Players.PlayerAdded:connect(function(Player)
			local VID = FrameworkInternalService.VisitId + 1
			FrameworkInternalService.VisitId = VID
			FrameworkHttpService.payload.players[tostring(Player.userId)] = {
				id = vid,
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
				if LastError then
					table.insert(FrameworkHttpService.payload.errors, {
						message = LastError,
						stack = Stack,
						time = os.time()
					})
				end
				
				Stack, LastError = {}, message;
			elseif LastError and messagetype == Enum.MessageType.MessageInfo then
				table.insert(Stack, message)
			end
		end)

		if game:GetFrameworkModule():findFirstChild"ClientErrorReporting" then
			game:GetFrameworkModule()["ClientErrorReporting"]:Destroy()
		end
		
		local CER = Instance.new("RemoteEvent")
		CER.Name = "ClientErrorReporting"
		CER.OnServerEvent:connect(function(Player, Errs)
			if type(Errs) == "table" and #Errs > 0 then
				for i = 1,#Errs do
					local Err = Errs[i]
					if typeof(Err) == "table" and Err.message and Err.stack and Err.time then
						Err.userid = Player.userId
						Err.username = Player.Name
						
						table.insert(FrameworkHttpService.payload.errors, Err)
					end
				end
			end
		end)
		CER.Parent = game:GetFrameworkModule()
		
		if game:GetFrameworkModule():findFirstChild"ClientInfoReporting" then
			game:GetFrameworkModule()["ClientInfoReporting"]:Destroy()
		end
		
		local CIR = Instance.new("RemoteEvent")
		CIR.Name = "ClientInfoReporting"
		CIR.OnServerEvent:connect(function(Player, Info)
			if FrameworkHttpService.payload.players[tostring(Player.userId)] and type(Info) == "table" and Info.device then
				FrameworkHttpService.payload.players[tostring(Player.userId)].device = Info.device
				FrameworkHttpService.payload.players[tostring(Player.userId)].kbe = Info.keyboardenabled
				FrameworkHttpService.payload.players[tostring(Player.userId)].tce = Info.touchenabled
				FrameworkHttpService.payload.players[tostring(Player.userId)].gse = Info.gyroscopeenabled
				FrameworkHttpService.payload.players[tostring(Player.userId)].gpe = Info.gamepadenabled
				FrameworkHttpService.payload.players[tostring(Player.userId)].ame = Info.accelerometerenabled
				FrameworkHttpService.payload.players[tostring(Player.userId)].vre = Info.vrenabled
			end
		end)
		CIR.Parent = game:GetFrameworkModule()
		
		game:GetService("MarketplaceService").ProcessReceipt = function(Receipt)
			local username = "Player#" .. Receipt.PlayerId;
			if game.Players:GetPlayerByUserId(Receipt.PlayerId) then
				username = game.Players:GetPlayerByUserId(Receipt.PlayerId).Name
			end
			
			table.insert(FrameworkHttpService.payload.sales, {
				type = "product",
				userid = Receipt.PlayerId,
				username = username,
				id = tostring(Receipt.PurchaseId),
				productid = Receipt.ProductId,
				robux = Receipt.CurrencySpent,
				purchased = true
			})
			
			return "framework.internal"
		end
		
		game:GetService("MarketplaceService").PromptPurchaseFinished:connect(function(player, assetid, purchased)
			local t = "asset"
			local info
			pcall(function()
				info = game.MarketplaceService:GetProductInfo(assetid)
			end)
			
			local robux
			if info then
				robux = info.PriceInRobux
				
				if info.AssetTypeId == 34 then
					t = "gamepass"
				end
				
				info = game.HttpService:JSONEncode(info)
			end
			
			table.insert(FrameworkHttpService.payload.sales, {
				type = t,
				userid = Player.userId,
				username = Player.Name,
				id = tostring(os.time() .. tostring(Player.userId)),
				assetid = assetid,
				robux = robux,
				purchased = purchased,
				info = info
			})
		end)
	elseif FrameworkModule.WebConnection.Connection.Value then
		local LastError = nil
		local Stack = {}
		local Module = game:GetFrameworkModule()
		local Next = 0
		local function ProcessQueue()
			if Next > os.time() then repeat wait() until Next <= os.time() end
			Next = os.time() + 1
			
			if #FrameworkHttpService.payload.ce == 0 then return end
			
			Module.ClientErrorReporting:FireServer(FrameworkHttpService.payload.ce)
			FrameworkHttpService.payload.ce = {}
		end
		
		local con
		con = game:GetService("LogService").MessageOut:connect(function(message, messagetype)
			if messagetype == Enum.MessageType.MessageInfo and message == "Stack End" then
				table.insert(Stack, message)
				
				local x = Module:WaitForChild("ClientErrorReporting", 60)
				if not x then return con:disconnect() end
				
				table.insert(FrameworkHttpService.payload.ce, {
					message = LastError,
					stack = Stack,
					time = os.time()
				})
				
				ProcessQueue()
				
				Stack, LastError = {}, nil
			elseif messagetype == Enum.MessageType.MessageError then
				if LastError then
					table.insert(FrameworkHttpService.payload.ce, {
						message = LastError,
						stack = Stack,
						time = os.time()
					})
					
					ProcessQueue()
				end
				
				Stack, LastError = {}, message;
			elseif LastError and messagetype == Enum.MessageType.MessageInfo then
				table.insert(Stack, message)
			end
		end)
		
		spawn(function()
			local CIR = Module:WaitForChild("ClientInfoReporting", 10)
			if not CIR then return end
			
			local uis = game:GetService("UserInputService")
			local device = nil
			if uis.VREnabled then
				device = "VR"
			elseif uis.TouchEnabled then
				device = "Mobile"
			elseif uis.GamepadEnabled then
				device = "Console"
			else
				device = "PC"
			end
			CIR:FireServer({
				device = device,
				keyboardenabled = uis.KeyboardEnabled,
				gyroscopeenabled = uis.GyroscopeEnabled,
				gamepadenabled = uis.GamepadEnabled,
				touchenabled = uis.TouchEnabled,
				accelerometerenabled = uis.AccelerometerEnabled,
				vrenabled = uis.VREnabled
			})
		end)
	end
	
	spawn(function()
		FrameworkHttpService:WaitUntilReady()
		
		if game:Is("Server") and FrameworkModule.WebConnection.Connection.Value and FrameworkHttpService.HttpEnabled then
			local WebConnection = {}
			for _,v in pairs(FrameworkModule.WebConnection:GetChildren()) do
				WebConnection[v.Name] = v.Value
			end
			
			FrameworkHttpService:SetProperty("WebConnection", WebConnection)
			FrameworkHttpService:LockProperty("WebConnection", 2)--
			
			-- Payloads
			if FrameworkHttpService.PayloadEnabled then
				local LastSuccessfulPayload = os.time()
				ThreadService:Thread(function()
					if LastSuccessfulPayload + 300 <= os.time() then
						FrameworkService:DebugOutput("Couldn't contact webserver for 5 minutes, destroying pending payload data.")
						FrameworkHttpService:ClearPayload()
					end
				end, {delay = 60, yield = false})
				
				ThreadService:Thread(function()
					local res = FrameworkHttpService:Post("payload", FrameworkHttpService:GetPayload(), {json=true})
					
					if res and res.success then
						LastSuccessfulPayload = os.time()
						FrameworkHttpService:ClearPayload()
					else
						game.FrameworkService:DebugOutput("Payload request failed.")
					end
				end, {delay = FrameworkHttpService.PayloadDelay, yield = true, onclose = true})
			else
				ThreadService:Thread(function()
					FrameworkHttpService:ClearPayload()
				end, {delay = 60, yield = false})
			end
			
			FrameworkService:Output("Connected to webservers!", game.Info)
		end
	end)
	
	FrameworkService:Output("Loaded successfully! Version", FrameworkService.Version, "Build", FrameworkService.Build)
	
	return FrameworkService
end