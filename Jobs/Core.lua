-- Core Job!

return function(a, b, c, d, e, f, g, h, i, j, k, l)
	game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

	local FrameworkService = game:GetService("FrameworkService")
	local ThreadService = game:GetService("ThreadService")
	local FrameworkInternalService = game:GetService("FrameworkInternalService")
	local FrameworkHttpService = game:GetService("FrameworkHttpService")
	local GuiService = game:GetService("GuiService")
	local FrameworkModule = game:GetFrameworkModule()

	--game:SetProperty("Info", "")
	game:LockProperty("Name", 2)

	if game:Is("Client") then
		spawn(function()
			local data = game:GetService("TeleportService"):GetLocalPlayerTeleportData()

			if typeof(data) == "table" then
				if data.___RsrvCode then
					game:GetService("MatchmakingService"):SendReserveCodeToServer(data.___RsrvCode, data.___PublicRsrv)
				end
			end
		end)

		spawn(function()
			FrameworkModule:WaitForChild("WebserverChat").OnClientEvent:connect(function(message, color, size)
				game.StarterGui:SetCore("ChatMakeSystemMessage", {
					Text = message; -- Required. Has to be a string!
					Color = color; -- Cyan is (0, 255 / 255, 255 / 255). Optional, defaults to white: Color3.new(255 / 255, 255 / 255, 243 / 255)
					Font = Enum.Font.SourceSansBold; -- Optional, defaults to Enum.Font.SourceSansBold
					FontSize = size; -- Optional, defaults to Enum.FontSize.Size18
				})
			end)
		end)
	end


	if game:Is("Server") then
		if game:GetFrameworkModule():findFirstChild"ClientToServerRedirection" then
			game:GetFrameworkModule()["ClientToServerRedirection"]:Destroy()
		end

		local CTSR = Instance.new("RemoteFunction")
		CTSR.Name = "ClientToServerRedirection"
		function CTSR.OnServerInvoke(Player, Service, Method, ...)
			local S = game:GetService(Service)
			return S[Method](S, ...)
		end
		CTSR.Parent = game:GetFrameworkModule()

		if game:GetFrameworkModule():findFirstChild"ClientLeaderboardUpdateTrigger" then
			game:GetFrameworkModule()["ClientLeaderboardUpdateTrigger"]:Destroy()
		end

		local CLUT = Instance.new("RemoteEvent")
		CLUT.Name = "ClientLeaderboardUpdateTrigger"
		CLUT.Parent = game:GetFrameworkModule()
	else
		game:GetFrameworkModule():WaitForChild("ClientLeaderboardUpdateTrigger").OnClientEvent:connect(function(ID)
			local LBS = game:GetService("LeaderboardService")
			LBS.OnUpdate:fire(ID)
		end)
	end


	if FrameworkModule.WebConnection.Connection.Value and game:Is("Server") then -- Payload Stuff!
		game.Players.PlayerAdded:connect(function(Player)
			local VID = FrameworkInternalService.VisitId + 1
			FrameworkInternalService.VisitId = VID
			FrameworkHttpService.payload.players[tostring(Player.userId)] = {
				id = VID,
				userid = Player.userId,
				username = Player.Name,
				joined = os.time(),
				age = Player.AccountAge,
				follow = Player.FollowUserId,
				bc = string.split(tostring(Player.MembershipType), ".")[3]
			}
			table.insert(FrameworkHttpService.payload.joined, {
				userid = Player.userId,
				username = Player.Name,
				joined = os.time()
			})
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

			table.insert(FrameworkHttpService.payload.left, {
				userid = Player.userId,
				username = Player.Name,
				left = os.time()
			})
		end)


		--print("Bro...")
		local PlsWork = Instance.new("Folder", workspace)
		PlsWork.Name = "PlsWork"
		local v1 = Instance.new("StringValue", workspace)
		v1.Name = "Msg"
		local v2 = Instance.new("StringValue", workspace)
		v2.Name = "MsgType"

		local LastError = nil
		local Stack = {}
		game:GetService("LogService").MessageOut:connect(function(message, messagetype)
			v1.Value = message
			v2.Value = tostring(messagetype)
			local x = v1:Clone()
			v2:Clone().Parent = x
			x.Parent = PlsWork
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
						Err.time = os.time()

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
				FrameworkHttpService.payload.players[tostring(Player.userId)].fse = Info.fullscreen
				FrameworkHttpService.payload.players[tostring(Player.userId)].vol = Info.volume
				FrameworkHttpService.payload.players[tostring(Player.userId)].msn = Info.sensitivity
				FrameworkHttpService.payload.players[tostring(Player.userId)].gsn = Info.gamepadsensitivity
				FrameworkHttpService.payload.players[tostring(Player.userId)].sql = Info.quality
			end
		end)
		CIR.Parent = game:GetFrameworkModule()

		game:GetService("MarketplaceService").ProcessReceipt = function(Receipt)
			local username = "Player#" .. Receipt.PlayerId;
			if game.Players:GetPlayerByUserId(Receipt.PlayerId) then
				username = game.Players:GetPlayerByUserId(Receipt.PlayerId).Name
			end

			local info
			pcall(function()
				info = game.MarketplaceService:GetProductInfo(Receipt.ProductId, 1)
				info = game.HttpService:JSONEncode(info)
			end)

			table.insert(FrameworkHttpService.payload.sales, {
				type = "product",
				userid = Receipt.PlayerId,
				username = username,
				id = tostring(Receipt.PurchaseId),
				productid = Receipt.ProductId,
				time = os.time(),
				robux = Receipt.CurrencySpent,
				info = info,
				purchased = true
			})

			return "framework.internal"
		end

		game:GetService("MarketplaceService").PromptGamePassPurchaseFinished:connect(function(player, assetid, purchased)
			local t = "gamepass"
			local info
			pcall(function()
				info = game.MarketplaceService:GetProductInfo(assetid, 2)
			end)

			local robux
			if info then
				robux = info.PriceInRobux

				info = game.HttpService:JSONEncode(info)
			end

			table.insert(FrameworkHttpService.payload.sales, {
				type = t,
				userid = player.userId,
				username = player.Name,
				id = tostring(os.time() .. tostring(player.userId)),
				assetid = assetid,
				robux = robux,
				purchased = purchased,
				time = os.time(),
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
			local _settings = {}
			pcall(function()
				_settings = UserSettings():GetService("UserGameSettings")
			end)
			CIR:FireServer({
				device = device,
				keyboardenabled = uis.KeyboardEnabled,
				gyroscopeenabled = uis.GyroscopeEnabled,
				gamepadenabled = uis.GamepadEnabled,
				touchenabled = uis.TouchEnabled,
				accelerometerenabled = uis.AccelerometerEnabled,
				vrenabled = uis.VREnabled,
				fullscreen = _settings and _settings:InFullScreen(),
				volume = _settings and _settings.MasterVolume,
				sensitivity = _settings and _settings.MouseSensitivity,
				gamepadsensitivity = _settings and _settings.GamepadCameraSensitivity,
				quality = _settings and string.split(tostring(_settings.SavedQualityLevel), ".")[3]
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

			local WebserverChat = FrameworkModule:findFirstChild("WebserverChat") or Instance.new("RemoteEvent", FrameworkModule)
			WebserverChat.Name = "WebserverChat"

			-- Payloads
			if FrameworkHttpService.PayloadEnabled then
				local function ProcessWebserverRequests(requests)
					if type(requests) == "string" then
						requests = game.HttpService:JSONDecode(requests)
					end

					for _,v in pairs(requests) do
						if v.type == "dataChange" then
							print("-- DATA CHANGE REQUEST --")
							print("ID:", v.id)
							print("UserID:", v.userid)
							print("Profile:", v.profile)
							print("Key:", game.FrameworkService:Unserialize(v.key))
							print("Value:", game.FrameworkService:Unserialize(v.value))
							print("-- EOR --")

							game:GetService("PlayerDataService"):LoadData(tonumber(v.userid), v.profile):Set(game.FrameworkService:Unserialize(v.key), game.FrameworkService:Unserialize(v.value))

							requests[_].complete = true
						elseif v.type == "storageDataChange" then
							print("-- STORAGE DATA CHANGE REQUEST --")
							print("ID:", v.id)
							print("Key:", game.FrameworkService:Unserialize(v.key))
							print("Value:", game.FrameworkService:Unserialize(v.value))
							print("-- EOR --")

							game:GetService("StorageService"):Set(game.FrameworkService:Unserialize(v.key), game.FrameworkService:Unserialize(v.value))

							requests[_].complete = true
						elseif v.type == "counterDataChange" then
							print("-- COUNTER DATA CHANGE REQUEST --")
							print("ID:", v.id)
							print("Key:", game.FrameworkService:Unserialize(v.key))
							print("Value:", game.FrameworkService:Unserialize(v.value))
							print("-- EOR --")

							game:GetService("CounterService"):Set(game.FrameworkService:Unserialize(v.key), game.FrameworkService:Unserialize(v.value))

							requests[_].complete = true
						elseif v.type == "shutdown" then
							for _,plr in pairs(game.Players:GetPlayers()) do
								plr:Kick((v.reason and v.reason ~= "") and v.reason or nil)
							end

							game.Players.PlayerAdded:connect(function(plr)
								plr:Kick((v.reason and v.reason ~= "") and v.reason or nil)
							end)

							print("-- SHUTDOWN REQUEST --")
							print("ID:", v.id)
							print("Reason:", v.reason)
							print("-- EOR --")

							requests[_].complete = true
						elseif v.type == "chat" then
							WebserverChat:FireAllClients(v.message,Color3.fromRGB(v.color.r, v.color.g, v.color.b), v.size)

							print("-- CHAT REQUEST --")
							print("ID:", v.id)
							print("Message:", v.message)
							print("Text Size:", v.size)
							print("Color:", Color3.fromRGB(v.color.r, v.color.g, v.color.b))
							print("-- EOR --")

							requests[_].complete = true
						elseif v.type == "teleport" and v.player then
							print("-- TELEPORT REQUEST --")
							print("ID:", v.id)
							local Plr = game.Players:GetPlayerByUserId(v.player)
							print("Player:", Plr)
							print("PlaceID:", v.placeid)
							print("JobID:", v.server)
							print("ReserveCode:", v.reserve)
							print("-- EOR --")

							if Plr then
								if v.reserve and v.reserve ~= "" then
									game:GetService("TeleportService"):TeleportToPrivateServer(v.placeid, v.reserve, {Plr})
								else
									game:GetService("TeleportService"):TeleportToPlaceInstance(v.placeid, v.server, Plr)
								end
							end

							requests[_].complete = true
						elseif v.type == "kick" and v.player then
							local plr = game.Players:GetPlayerByUserId(v.player)

							if plr then
								plr:Kick((v.reason and v.reason ~= "") and v.reason or nil)
							end

							requests[_].complete = true
						elseif v.type == "respawn" and v.player then
							local plr = game.Players:GetPlayerByUserId(v.player)

							if plr then
								plr:LoadCharacter()
							end

							requests[_].complete = true
						elseif v.type == "kill" and v.player then
							local plr = game.Players:GetPlayerByUserId(v.player)

							if plr and plr.Character and plr.Character:findFirstChild("Humanoid") then
								plr.Character.Humanoid.Health = 0
							end

							requests[_].complete = true
						elseif v.type == "heal" and v.player then
							local plr = game.Players:GetPlayerByUserId(v.player)

							if plr and plr.Character and plr.Character:findFirstChild("Humanoid") then
								plr.Character.Humanoid.Health = plr.Character.Humanoid.MaxHealth
							end

							requests[_].complete = true
						elseif v.type == "explode" and v.player then
							local plr = game.Players:GetPlayerByUserId(v.player)

							if plr and plr.Character and plr.Character:findFirstChild("HumanoidRootPart") then
								local e = Instance.new("Explosion", plr.Character.HumanoidRootPart)
								e.BlastRadius = 4
								e.BlastPressure = 750000
								e.DestroyJointRadiusPercent = 25
								e.ExplosionType = "CratersAndDebris"
								e.Position = plr.Character.HumanoidRootPart.Position

								game.Debris:AddItem(e, 2)
							end

							requests[_].complete = true
						elseif v.type == "ban" and tonumber(v.player) then
							local plr = game.Players:GetPlayerByUserId(v.player)

							--if plr then
								local data = game:GetService("PlayerDataService"):LoadData(tonumber(v.player))
								if data then
									data:iSet("Banned", true)
									data:iSet("BanReason", (v.reason and v.reason ~= "") and v.reason or nil)
									data:iSet("BanLift", os.time() + (v.seconds or 999999999))
									if not data:iGet("BanHistory") then
										data:iSet("BanHistory",{{os.time(), v.seconds, v.reason}})
									else
										local bh = data:iGet("BanHistory")
										table.insert(bh, {os.time(), v.seconds, v.reason})
										data:iSet("BanHistory", bh)
									end
									data.lastEdit = data.lastSave + 1
									if not plr then data:Save() end
								end
								if plr then plr:Kick((v.reason and v.reason ~= "") and v.reason or nil) end
							--end

							requests[_].complete = true
						elseif v.type == "serverBan" and v.player then
							local plr = game.Players:GetPlayerByUserId(v.player)

							if plr then
								plr:Kick((v.reason and v.reason ~= "") and v.reason or nil)

								game.Players.PlayerAdded:connect(function(plr)
									if plr.userId == v.player then
										plr:Kick((v.reason and v.reason ~= "") and v.reason or nil)
									end
								end)
							end

							requests[_].complete = true
						end
					end

					game.FrameworkHttpService.payload.requests = requests
				end

				local LastSuccessfulPayload = os.time()
				ThreadService:Thread(function()
					if LastSuccessfulPayload + 300 <= os.time() then
						FrameworkService:DebugOutput("Couldn't contact webserver for 5 minutes, destroying pending payload data.")
						FrameworkHttpService:ClearPayload()
					end
				end, {delay = 60, yield = false})

				game:BindToClose(function() wait(7)
					local res = FrameworkHttpService:Post("payload", FrameworkHttpService:GetPayload(), {json=true})

					if res and res.success then
						LastSuccessfulPayload = os.time()
						FrameworkHttpService:ClearPayload()
						ProcessWebserverRequests(res.requests)
					else
						game.FrameworkService:DebugOutput("Payload request failed.")
					end end)

				ThreadService:Thread(function()
					if game.Players.NumPlayers == 0 then wait(3) end
					local res = FrameworkHttpService:Post("payload", FrameworkHttpService:GetPayload(), {json=true})

					if res and res.success then
						LastSuccessfulPayload = os.time()
						FrameworkHttpService:ClearPayload()
						ProcessWebserverRequests(res.requests)
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
