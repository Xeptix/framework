--[[
	File: XeptixFrameworkPlugin.lua
	Author: Xeptix
	Info: Handles the plugin itself
--]]



print("Loading Xeptix Framework in 5 seconds...")
wait(5.2)



-- Main variables
Version = script:WaitForChild("INSTALL"):WaitForChild("ReplicatedStorage"):WaitForChild("XeptixFrameworkModule"):WaitForChild("Internal Stuff"):WaitForChild("Var"):WaitForChild("Version").Value

Installed = false
InstallScript = nil -- the "Xeptix Framework" module (if installed)

RbxUtility = LoadLibrary("RbxUtility")
OnInstall = RbxUtility.CreateSignal()
OnUninstall = RbxUtility.CreateSignal()
OnUpdate = RbxUtility.CreateSignal()

function AutosizeCanvas(ScrollingFrame, paddingOverride)
	local padding = 0
	
	if not paddingOverride then
		paddingOverride = padding
	end
	
	local function UpdateSize()
		local CanvasSizeX, CanvasSizeY = 0, 0
		
		local function Recursive(Parent)
			for _,v in pairs(Parent:GetChildren())do
				Recursive(v)

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

		Recursive(ScrollingFrame)
		
		ScrollingFrame.CanvasSize = UDim2.new(0, CanvasSizeX + paddingOverride, 0, CanvasSizeY + paddingOverride)
	end
	
	ScrollingFrame.DescendantAdded:connect(UpdateSize)
	ScrollingFrame.DescendantRemoving:connect(UpdateSize)
	ScrollingFrame.AncestryChanged:connect(UpdateSize)
	ScrollingFrame.Changed:connect(function(prop)
		if prop == "Position" or prop == "Size" then -- we dont want to spam this every time you scroll
			UpdateSize()
		end
	end)
	
	UpdateSize()
end

function SeparateString(String, Separator, UnpackResults)
	local Parts = {}
	for x in String:gmatch("[^"..Separator.."]+") do
		table.insert(Parts, x)
	end
	
	if UnpackResults then
		return unpack(Parts)
	end
	
	return Parts
end





-- We'll cache the CreatorId so we can tag it in the DCRequest. This way I can see how many people actually use the framework :D
CreatorId = game.CreatorId
if CreatorId == 0 and plugin:GetSetting("CreatorId") then
	CreatorId = plugin:GetSetting("CreatorId")
elseif CreatorId > 0 then
	plugin:SetSetting("CreatorId", CreatorId)
end





-- Setting Stuff
function Table2Json(S)
	local T = {}
	for _,v in pairs(S) do
		if type(v) == "table" then
			T[_] = v[1]
		else
			T[_] = v
		end
	end
	
	return game:GetService"HttpService":JSONEncode(T)
end

DefaultSettings, MySettings = { -- Setting = {DefaultValue, Info, NumMin, MumMax}
	PlayerSaveDatabaseName = {"PlayerDataStore_PlayerData", [[* this is the name for the database, when changed, all data is lost, although you can change it back to get that data back.

* it's not recommended to put any non-alphanumerical characters or else you may break the database. Be sure to test the saving and loading after altering the name to ensure the name does not break any of roblox's datastore name rules.]]},
	
	
	AutosaveEnabled = {true, [[* if true, the game will autosave every 120 seconds.

* no matter if this is enabled or not, the game will still save when the player leaves or the server shutsdown, there is currently no way to change this.
	
* if false, the game will not save unless you manually do call :Save() or the above action(s) happen.]]},
		
	PlayerListAPI = {false, [[* if true, the PlayerList API will be enabled. This allows you to alter how the playerlist looks, but maintaining the default look/functionality. For example, you can change the colors of peoples name(s)/background(s), and you can add colored prefixes/suffixes to usernames. You can also add buttons to the menu that slides out when you click on a username.]]},
	
	ChatAPI = {false, [[* if true, the Chat API will be enabled. This allows you to alter how the chat looks. For example, you can change the colors of peoples name(s)/chat(s)/background(s), and you can add colored prefixes/suffixes to usernames.

* you must configure your place to allow Bubble Chats only, for this chat to behave as expected!]]},
	
	ChatRemoveDelay = {45, [[* the amount of seconds to wait before a chat is removed.

* must be between 20 and 120 (20 seconds to 2 minutes).

* the ChatAPI setting must be enabled for this to take effect - this does not effect the ROBLOX chat.]], 20, 120},
	
	RealWorldGameTime = {false, [[* if true, the game's TimeOfDay will automatically synchronize with the real life time of day (in California).]]},
	
	
	DeveloperProductAPIEnabled = {false, [[* enables the Developer Product API.

* if enabled, MarketplaceService.ProcessReceipt will be used by Xeptix Framework! Instead of using ProccessReceipt, please look at the "0000" ModuleScript inside of ReplicatedStorage > XeptixFrameworkModule > Developer Products! That module will show you how to use our Developer Product system!]]},
	
	
	ClientCanUseBanAPI = {false, [[* allows the client to use :Kick, :Ban, and :Unban functions.

* if true, exploiters can possibly kick/ban players from your game! To ensure proper security, it is advised you handle all kicking and banning from the server!]]},
	
	
	CreatorInterfaceEnabled = {false, [[* If true, the Creator Interface will be enabled

* to use the Creator Interface, while in-game (not in studio), press CreatorInterfaceHotkey]]},
	
	
	CreatorInterfaceHotkey = {"30", [[* The key you press to open the Creator Interface while in game

* Only works if CreatorInterfaceEnabled is true

* By default it is the "F5" key, which is "30" in bytecode

* Example hotkeys: "z", "1", "30" (F5)]]},
}, {}
script.INSTALL.ReplicatedStorage.XeptixFrameworkModule["Internal Stuff"].Var.SJSON.Value = Table2Json(DefaultSettings)





-- install, uninstall, and update functions
function Install()
	wait()
	if Installed then return end
	
	local S
	for _,v in pairs(script.INSTALL:GetChildren())do
		local P
		if game:FindFirstChild(v.Name) then
			P = game:FindFirstChild(v.Name)
		elseif v.Name == "StarterPlayerScripts" then
			P = game.StarterPlayer.StarterPlayerScripts
		end
		
		if P then
			for __,vv in pairs(v:GetChildren()) do
				for ___,vvv in pairs(P:GetChildren()) do
					if vvv.Name == vv.Name and vvv.ClassName == vv.ClassName then
						vvv:Destroy()
					end
				end
				
				local x = vv:Clone()
				x.Parent = P
				if x.Name == "XeptixFrameworkModule" and P == game.ReplicatedStorage then
					S = x
				elseif x.ClassName == "Script" then
					x.Disabled = false
				elseif x.ClassName == "LocalScript" then
					x.Disabled = false
				end
			end
		else
			warn("Xeptix Framework Issue ID.15015 - " .. v.Name .. " not found in DataModel!")
			return false
		end
	end
	
	Installed = true
	InstallScript = S
	OnInstall:fire()
	return true
end

function Uninstall()
	wait()
	if not Installed then return end
	
	for _,v in pairs(script.INSTALL:GetChildren())do
		local P
		if game:FindFirstChild(v.Name) then
			P = game:FindFirstChild(v.Name)
		elseif v.Name == "StarterPlayerScripts" then
			P = game.StarterPlayer.StarterPlayerScripts
		end
		
		if P then
			for __,vv in pairs(v:GetChildren()) do
				for ___,vvv in pairs(P:GetChildren()) do
					if vvv.Name == vv.Name and vvv.ClassName == vv.ClassName then
						vvv:Destroy()
					end
				end
			end
		end
	end
	
	for _,v in pairs(script.UNINSTALL:GetChildren())do
		local P
		if game:FindFirstChild(v.Name) then
			P = game:FindFirstChild(v.Name)
		elseif v.Name == "StarterPlayerScripts" then
			P = game.StarterPlayer.StarterPlayerScripts
		end
		
		if P then
			for __,vv in pairs(v:GetChildren()) do
				for ___,vvv in pairs(P:GetChildren()) do
					if vvv.Name == vv.Name then
						vvv:Destroy()
					end
				end
			end
		end
	end
	
	Installed = false
	InstallScript = nil
	OnUninstall:fire()
	return true
end

function Update()
	wait()
	if not Installed or not InstallScript then return end
	local DP, EC, ES, FC, FS,S = {},{},{},{},{},"[]"
	local Backup = InstallScript:Clone()
	local function OnError() -- if an error occures while updating, restore the old version
		Installed = false
		Install()
		
		Backup.Parent = InstallScript.Parent
		InstallScript:Destroy()
		InstallScript = Backup
	end
	
	-- backup their settings
	S = InstallScript["Internal Stuff"].Var.SJSON.Value
	local DCK
	if InstallScript["Internal Stuff"].Var:findFirstChild("DCK") then
		DCK = InstallScript["Internal Stuff"].Var.DCK:Clone()
	end
	
	-- backup their dev products
	for _,v in pairs(InstallScript["Developer Products"]:GetChildren())do
		if v.Name ~= "0000" then
			table.insert(DP, v:Clone())	
		end
	end
	
	-- backup their events
	for _,v in pairs(InstallScript["Events (Client)"]:GetChildren())do
		table.insert(EC, v:Clone())	
	end
	for _,v in pairs(InstallScript["Events (Server)"]:GetChildren())do
		table.insert(ES, v:Clone())	
	end
	
	-- backup their functions
	for _,v in pairs(InstallScript["Functions (Client)"]:GetChildren())do
		table.insert(FC, v:Clone())	
	end
	for _,v in pairs(InstallScript["Functions (Server)"]:GetChildren())do
		table.insert(FS, v:Clone())	
	end
	
	
	
	-- apply the updated version to the place
	for _,v in pairs(script.UNINSTALL:GetChildren())do
		local P
		if game:FindFirstChild(v.Name) then
			P = game:FindFirstChild(v.Name)
		elseif v.Name == "StarterPlayerScripts" then
			P = game.StarterPlayer.StarterPlayerScripts
		end
		
		if P then
			for __,vv in pairs(v:GetChildren()) do
				for ___,vvv in pairs(P:GetChildren()) do
					if vvv.Name == vv.Name then
						vvv:Destroy()
					end
				end
			end
		end
	end
	
	for _,v in pairs(script.INSTALL:GetChildren())do
		local P
		if game:FindFirstChild(v.Name) then
			P = game:FindFirstChild(v.Name)
		elseif v.Name == "StarterPlayerScripts" then
			P = game.StarterPlayer.StarterPlayerScripts
		end
		
		if P then
			for __,vv in pairs(v:GetChildren()) do
				for ___,vvv in pairs(P:GetChildren()) do
					if vvv.Name == vv.Name and vvv.ClassName == vv.ClassName then
						vvv:Destroy()
					end
				end
				
				local x = vv:Clone()
				x.Parent = P
				if x.Name == "XeptixFrameworkModule" and P == game.ReplicatedStorage then
					InstallScript = x
					x["Internal Stuff"].Var.SJSON.Value = S
					if DCK then
						DCK.Parent = x["Internal Stuff"].Var
					end
					S = ""
					
					for __,vv in pairs(DP) do
						vv.Parent = x["Developer Products"]
					end
					for __,vv in pairs(EC) do
						vv.Parent = x["Events (Client)"]
					end
					for __,vv in pairs(ES) do
						vv.Parent = x["Events (Server)"]
					end
					for __,vv in pairs(FC) do
						vv.Parent = x["Functions (Client)"]
					end
					for __,vv in pairs(FS) do
						vv.Parent = x["Functions (Server)"]
					end
				elseif x.ClassName == "Script" then
					x.Disabled = false
				elseif x.ClassName == "LocalScript" then
					x.Disabled = false
				end
			end
		else
			warn("Xeptix Framework Issue ID.15015 - " .. v.Name .. " not found in DataModel!")
			return OnError()
		end
	end
		
	if S ~= "" then
		return OnError() -- something went wrong
	end
	
	
	OnUpdate:fire()
	return true
end









-- Setup the gui
local Gui = script:WaitForChild("XF.UI")
Gui.Parent = game:GetService("CoreGui")

local AConnection, BConnection, CConnection
function Alert(Title, Text, ShowOpenAfter)
	local Open
	for _,v in pairs(Gui:GetChildren()) do
		if v.Visible and v ~= Gui.Alert then
			Open = v
			v.Visible = false
		end
	end
	
	if AConnection then AConnection:disconnect() end
	AConnection = Gui.Alert.Box.Close.MouseButton1Click:connect(function()
		Gui.Alert.Visible = false
		
		if ShowOpenAfter and Open then
			Open.Visible = true
		end
	end)
	
	Gui.Alert.Box.Title.Text = Title
	Gui.Alert.Box.Message.Text = Text
	Gui.Alert.Visible = true
end

local function YesOrNo(Title,Text,ShowOpenAfter)
	local Open
	for _,v in pairs(Gui:GetChildren()) do
		if v.Visible and v ~= Gui.YesOrNo then
			Open = v
			v.Visible = false
		end
	end
	
	if BConnection then BConnection:disconnect() end
	if CConnection then CConnection:disconnect() end

	Gui.YesOrNo.Box.Title.Text = Title
	Gui.YesOrNo.Box.Message.Text = Text

	local Answer
	BConnection = Gui.YesOrNo.Box.No.MouseButton1Click:connect(function()
		Answer = false
	end)
	CConnection = Gui.YesOrNo.Box.Yes.MouseButton1Click:connect(function()
		Answer = true
	end)

	repeat wait() until Answer ~= nil

	Gui.YesOrNo.Visible = false
	if ShowOpenAfter and Open then
		Open.Visible = true
	end

	return Answer
end


function updateMenuButtons()
	if Installed then
		Gui.Menu.Box.Install.Visible = false
		Gui.Menu.Box.Uninstall.Visible = true
		Gui.Menu.Box.Connect.Visible = true
		Gui.Menu.Box.Stats.Visible = true
		Gui.Menu.Box.Settings.Visible = true
		Gui.Menu.Box.Docs.Visible = true
		
		if InstallScript["Internal Stuff"].Var:findFirstChild("DCK") then
			Gui.Menu.Box.Connect.Button.Visible = false
			Gui.Menu.Box.Connect.TextScaled = true
			Gui.Menu.Box.Connect.Text = "This game is currently connected to DevCircle servers! Visit https://www.devcircle.net/framework to manage this place!"
		else
			Gui.Menu.Box.Connect.Button.Visible = true
			Gui.Menu.Box.Connect.TextScaled = false
			Gui.Menu.Box.Connect.Text = "This game is currently not connected to DevCircle servers! Would you like to connect?"
		end
	else
		Gui.Menu.Box.Install.Visible = true
		Gui.Menu.Box.Uninstall.Visible = false
		Gui.Menu.Box.Connect.Visible = false
		Gui.Menu.Box.Stats.Visible = false
		Gui.Menu.Box.Settings.Visible = false
		Gui.Menu.Box.Docs.Visible = false
	end
end

updateMenuButtons()
OnInstall:connect(updateMenuButtons)
OnUninstall:connect(updateMenuButtons)
OnUpdate:connect(updateMenuButtons)

Gui.Menu.Box.Connect.Button.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
	for _,v in pairs(Gui:GetChildren())do if v.Visible then return end end
	
	Gui.Connect.Visible = true
end)

Gui.Menu.Box.Stats.Button.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
	for _,v in pairs(Gui:GetChildren())do if v.Visible then return end end
	
	Gui.Stats.Visible = true
end)

Gui.Menu.Box.Settings.Button.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
	for _,v in pairs(Gui:GetChildren())do if v.Visible then return end end
	
	Gui.Settings.Visible = true
end)

Gui.Menu.Box.Docs.Button.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
	for _,v in pairs(Gui:GetChildren())do if v.Visible then return end end
	
	Gui.Docs.Visible = true
end)

Gui.Menu.Box.Install.Button.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
	for _,v in pairs(Gui:GetChildren())do if v.Visible then return end end
	
	Gui.Install.Visible = true
end)
	
Gui.Menu.Box.Connect.Button.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
	for _,v in pairs(Gui:GetChildren())do if v.Visible then return end end
	
	Gui.Connect.Visible = true
end)

Gui.Menu.Box.Uninstall.Button.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
	for _,v in pairs(Gui:GetChildren())do if v.Visible then return end end
	
	Gui.Uninstall.Visible = true
end)

Gui.Menu.Box.Version.Text = "v" .. Version


Gui.Install.Box.Install.MouseButton1Click:connect(function()
	local success = Install()
	
	if success then
		Alert("Xeptix Framework", "Xeptix Framework has successfully been installed to your game! For information on how to use it, go to the Xeptix Framework Plugin and click \"Documentation\"!")
	else
		Alert("Xeptix Framework", "An error occured while installing Xeptix Framework! Please try again later!")
	end
end)
Gui.Uninstall.Box.Uninstall.MouseButton1Click:connect(function()
	local success = Uninstall()
	
	if success then
		Alert("Xeptix Framework", "Xeptix Framework has successfully been uninstalled from your game! Feel free to PM improvement ideas to Xeptix!")
	else
		Alert("Xeptix Framework", "An error occured while uninstalling Xeptix Framework! Please try again later!")
	end
end)

Gui.Install.Box.Close.MouseButton1Click:connect(function()
	Gui.Install.Visible = false
end)
Gui.Uninstall.Box.Close.MouseButton1Click:connect(function()
	Gui.Uninstall.Visible = false
end)








-- check if v2 is installed
local x = game:FindFirstChild("XeptixFrameworkModule", true) or game:FindFirstChild("XeptixFramework", true)
if x and x:IsA("ModuleScript") and x.Parent == game.ReplicatedStorage then
	Installed = true
	InstallScript = x
	
	if x["Internal Stuff"].Var.Version.Value ~= Version then
		if Update() then
			Alert("Xeptix Framework Updated", "This place's version of Xeptix Framework has been updated to v"..Version.."!\nYou can view the update log in the Xeptix Framework menu!")
		else
			Alert("Xeptix Framework Error", "An error occured while updating this place's version of Xeptix Framework! Please PM this issue to Xeptix to get it resolved!")
		end
	end
	
	OnInstall:fire()
end



-- check if v1 is installed, if so, convert to v2 immediately
local x1, x2, x3, x4 =
	game.ReplicatedStorage:FindFirstChild("[Xeptix Framework]"), -- x1
	game.ReplicatedStorage:FindFirstChild("Xeptix Framework [Settings]"), -- x2
	game.ServerScriptService:FindFirstChild("Xeptix Framework [Server]"), -- x3
	game.StarterGui:FindFirstChild("Xeptix Framework [Client]") -- x4
	
if x1 and x2 and x3 and x4 and not Installed then
	Install()
	
	-- restore v1 settings
	local S = {}
	for _,v in pairs(x2:GetChildren())do
		if v.Name ~= "IntroTexts" then
			local val = tostring(v.Value)
			S[v.Name] = val
		end
	end
	
	InstallScript["Internal Stuff"].Var.SJSON.Value = game.HttpService:JSONEncode(S)
	
	-- restore v1 events/functions
	for _,v in pairs(x3.Events:GetChildren())do
		v.Parent = InstallScript["Events (Server)"]
	end
	for _,v in pairs(x4.Events:GetChildren())do
		v.Parent = InstallScript["Events (Client)"]
	end
	
	for _,v in pairs(x3.Functions:GetChildren())do
		v.Parent = InstallScript["Functions (Server)"]
	end
	for _,v in pairs(x4.Functions:GetChildren())do
		v.Parent = InstallScript["Functions (Client)"]
	end
	
	-- remove the old version of Xeptix Framework
	x1:Destroy()
	x2:Destroy()
	x3:Destroy()
	x4:Destroy()
	
	OnUpdate:fire()
	Alert("Xeptix Framework V2!", "Congradulations! Your place has been updated to Xeptix Framework V2!\nNow, to use the plugin's features, click \"Xeptix Framework\" in your Plugins Tab!\n\nNOTE: All of your Functions/Events have been moved to ReplicatedStorage > XeptixFrameworkModule!")
end









-- show file-open alert
if not Gui.Alert.Visible and not plugin:GetSetting("StayClosed") then
	Gui.FileOpenAlert.Visible = true
	
	Gui.FileOpenAlert.Close.MouseButton1Click:connect(function()
		Gui.FileOpenAlert.Visible = false
	end)
	
	Gui.FileOpenAlert.NeverShow.MouseButton1Click:connect(function()
		Gui.FileOpenAlert.Visible = false
		plugin:SetSetting("StayClosed", true)
	end)
end








-- setup the game.OnClose conflict system & stats gui
local ScriptsWithConflict = {}
local Scripts = {}
function UpdateConflictGui()
	local Scr
	local ITR = {}
	for i, v in pairs(ScriptsWithConflict) do
		if i and v and i.Parent then
			Scr = i
		end
	end
	
	if Scr and Installed then
		if Gui.FileOpenAlert.Visible then
			local success
			repeat wait(.3)
				success = true
				for _,v in pairs(Gui:GetChildren()) do
					if v.Visible then
						success = false
						break
					end
				end
			until success
		end
		
		if not Scr or not Scr.Parent then
			Gui.Conflict.Visible = false
			return
		end
		
		Gui.Conflict.Visible = true
		Gui.Conflict.Message.Text = "Whoops! It appears as though the script \"game." .. Scr:GetFullName() .. "\" uses game.OnClose! With the framework installed, you must use the framework.OnClose event instead!\n\nOnce you fix this issue, this message will automatically go away!"
	else
		Gui.Conflict.Visible = false
	end
end

OnInstall:connect(UpdateConflictGui)
OnUninstall:connect(UpdateConflictGui)

function UpdateStatsGui()
	local text = ("This Game's Script Stats:\n\nTotal #Scripts: %s\n#Scripts: %s\n#LocalScripts: %s\n#Modulescripts: %s\n\nTotal #Lines: %s\nAverage Lines Per Script: %s\n\nTotal #Characters: %s\nAverage Characters Per Line: %s\nAverage Characters Per Script: %s\n\n\nNOTICE: %s Scripts were excluded due to being a duplicate of a previously processed script!")
	
	local DuplicateContainer = {}
	local NumDuplicates = 0
	local NumScripts = 0
	local NumServerScripts = 0
	local NumLocalScripts = 0
	local NumModuleScripts = 0
	local TotalLines = 0
	local TotalCharacters = 0
	local AverageCharactersPerLine = 0
	local AverageCharactersPerScript = 0
	local AverageLinesPerScript = 0
	local BlankLines = 0


	local function CheckForDuplicate(Script)
		local IsScript = Script.ClassName == "Script" or Script.ClassName == "LocalScript" or Script.ClassName == "ModuleScript"

		if not IsScript then
			return false
		end
		
		local X = script.INSTALL:FindFirstChild(Script.Name, true)
		if Installed and X and X.Parent.Name == Script.Parent.Name and (X.ClassName == "Script" or X.ClassName == "LocalScript" or X.ClassName == "ModuleScript") then
			return false
		end

		for _,v in pairs(DuplicateContainer) do
			if v.Source == Script.Source then
				return true, true
			end
		end

		return true, false
	end	
	
	function Recursive(Parent)
		for _,v in pairs(Parent:GetChildren()) do
			if Parent == game or Parent.Parent == game then
				wait()
			end

			Recursive(v)

			local Valid, Duplicate = CheckForDuplicate(v)
			if Valid and not Duplicate then
				table.insert(DuplicateContainer, v)

				NumScripts = NumScripts + 1
				if v.ClassName == "Script" then
					NumServerScripts = NumServerScripts + 1
				elseif v.ClassName == "LocalScript" then
					NumLocalScripts = NumLocalScripts + 1
				elseif v.ClassName == "ModuleScript" then
					NumModuleScripts = NumModuleScripts + 1
				end

				local Lines, Characters = 0, 0
				for i in v.Source:gmatch('[^\n]+') do
					Lines = Lines + 1
					TotalLines = TotalLines + 1

					Characters = Characters + #i
					TotalCharacters = TotalCharacters + #i
				end
				
				for i = 1, #v.Source do
					if v.Source:sub(i, i) == "\n" and v.Source:sub(i+1, i+1) == "\n" then
						Lines = Lines + 1
						TotalLines = TotalLines + 1
						BlankLines = BlankLines + 1
					end					
				end
			elseif Duplicate then
				NumDuplicates = NumDuplicates + 1
			end
		end
	end

	pcall(function() Recursive(game.Workspace) end)
	pcall(function() Recursive(game.Lighting) end)
	pcall(function() Recursive(game.ReplicatedFirst) end)
	pcall(function() Recursive(game.ReplicatedStorage) end)
	pcall(function() Recursive(game.ServerScriptService) end)
	pcall(function() Recursive(game.ServerStorage) end)
	pcall(function() Recursive(game.StarterGui) end)
	pcall(function() Recursive(game.StarterPack) end)
	pcall(function() Recursive(game.StarterPlayer) end)
	pcall(function() Recursive(game.Teams) end)
	pcall(function() Recursive(game.TestService) end)
	pcall(function() Recursive(game.HttpService) end)
	
	AverageCharactersPerLine = TotalCharacters / (TotalLines - BlankLines)
	AverageCharactersPerScript = TotalCharacters / NumScripts
	AverageLinesPerScript = TotalLines / NumScripts

	text = text:format(NumScripts, NumServerScripts, NumLocalScripts, NumModuleScripts, TotalLines, math.floor(AverageLinesPerScript), TotalCharacters, math.floor(AverageCharactersPerLine), math.floor(AverageCharactersPerScript), NumDuplicates)
	Gui.Stats.Box.Message.Text = text
end

Gui.Stats.Box.Close.MouseButton1Click:connect(function()
	Gui.Stats.Visible = false
end)

Gui.Stats.Changed:connect(function()
	Gui.Stats.Box.Message.Text = "Gathering Latest Statistics..."
	if Gui.Stats.Visible then
		UpdateStatsGui()
	end
end)


function CheckObj(o)
	pcall(function()
		if o and o.Name ~= "XeptixFrameworkModule" and (o:IsA("Script") or o:IsA("ModuleScript") or o:IsA("LocalScript")) then
			local function CheckSource()
				if o.Source:gsub(" ", ""):gsub("	", ""):gsub("\n", ""):lower():find("game.onclose=") then
					ScriptsWithConflict[o] = true
				else
					ScriptsWithConflict[o] = false
				end
				
				UpdateConflictGui()
			end
			
			o.Changed:connect(CheckSource)
			CheckSource()
			
			Scripts[o] = true
		end
	end)
end

game.DescendantAdded:connect(CheckObj)
spawn(function()
	function abc123(p)
		for _,v in pairs(p:GetChildren())do
			abc123(v)
			CheckObj(v)
			
			if math.random(10) == 1 then wait() end
		end
	end
	
	abc123(game.Workspace)
	abc123(game:GetService"Lighting")
	abc123(game:GetService"ReplicatedFirst")
	abc123(game:GetService"ReplicatedStorage")
	abc123(game:GetService"ServerScriptService")
	abc123(game:GetService"ServerStorage")
	abc123(game:GetService"StarterGui")
	abc123(game:GetService"StarterPack")
	abc123(game:GetService"StarterPlayer")
	abc123(game:GetService"HttpService")
end)







-- settings gui
local STemplate = Gui.Settings.Box.Settings.Template:Clone()
Gui.Settings.Box.Info.Path.Close.MouseButton1Click:connect(function()
	Gui.Settings.Box.Info.Visible = false
	Gui.Settings.Box.Settings.Visible = true
end)


local SettingsConnections = {}
function UpdateSettings() -- this updates the settings gui with all the settings and such
	Gui.Settings.Box.Info.Visible = false
	Gui.Settings.Box.Settings.Visible = true
	Gui.Settings.Box.Settings:ClearAllChildren()
	
	for _,v in pairs(SettingsConnections) do
		v:disconnect()
	end
	SettingsConnections = {}
	
	if not Installed then return end
	
	for _,v in pairs(DefaultSettings) do
		local MyValue = MySettings[_]
		if MyValue == nil then
			MyValue = v[1]
		end
		
		if type(v[1]) ~= type(MyValue) then
			MyValue = v[1]
		end
		
		local Label = STemplate:Clone()
		Label.Parent = Gui.Settings.Box.Settings
		Label.Position = UDim2.new(0,0,0,(Label.AbsoluteSize.Y+5)*(#Gui.Settings.Box.Settings:GetChildren()-1))
		Label.Name = _
		Label.Text = _
		
		Label.Info.MouseButton1Click:connect(function()
			Gui.Settings.Box.Info.Info.Text = v[2]
			Gui.Settings.Box.Info.Path.Text = "Setting > " .. _
			Gui.Settings.Box.Info.Visible = true
			Gui.Settings.Box.Settings.Visible = false
		end)
		
		if type(v[1]) == "number" then
			Label.Edit.Number.Visible = true
			local function Update()
				Label.Edit.Number.Value.Text = MyValue
			end
			
			Label.Edit.Number.Value.Changed:connect(function()
				if not Label.Parent then return end
				
				if Label.Edit.Number.Value.Text == "-" or Label.Edit.Number.Value.Text == "" then
					MyValue = 0
				else
					MyValue = tonumber(Label.Edit.Number.Value.Text) or 0
					Update()
				end
				
				if v[3] and MyValue < v[3] then
					MyValue = v[3]
				elseif v[4] and MyValue > v[4] then
					MyValue = v[4]
				end
				
				MySettings[_] = MyValue
			end)
			Label.Edit.Number.Value.FocusLost:connect(Update)
			
			Label.Edit.Number.Up.MouseButton1Click:connect(function()
				MyValue = MyValue + 1
				Update()
				
				if v[3] and MyValue < v[3] then
					MyValue = v[3]
				elseif v[4] and MyValue > v[4] then
					MyValue = v[4]
				end
				
				MySettings[_] = MyValue
			end)
			Label.Edit.Number.Down.MouseButton1Click:connect(function()
				MyValue = MyValue - 1
				Update()
				
				if v[3] and MyValue < v[3] then
					MyValue = v[3]
				elseif v[4] and MyValue > v[4] then
					MyValue = v[4]
				end
				
				MySettings[_] = MyValue
			end)
			
			Update()
		elseif type(v[1]) == "boolean" then
			Label.Edit.Boolean.Visible = true
			local function Update()
				if MyValue then
					Label.Edit.Boolean.Value.Text = "True (Click to Toggle)"
				else
					Label.Edit.Boolean.Value.Text = "False (Click to Toggle)"
				end
			end
			
			Label.Edit.Boolean.Value.MouseButton1Click:connect(function()
				MyValue = not MyValue
				Update()
				
				MySettings[_] = MyValue
			end)
			
			Update()
		else
			Label.Edit.String.Visible = true
			local function Update()
				Label.Edit.String.Value.Text = tostring(MyValue)
			end
			
			Label.Edit.String.Value.Changed:connect(function()
				if not Label.Parent then return end
				
				MyValue = Label.Edit.String.Value.Text
				
				MySettings[_] = MyValue
			end)
			
			Update()
		end
	end
end


function UpdateMySettings()
	if Installed then
		MySettings = game.HttpService:JSONDecode(InstallScript["Internal Stuff"].Var.SJSON.Value)
	else
		MySettings = DefaultSettings
	end
	
	UpdateSettings()
end

UpdateMySettings()
OnInstall:connect(UpdateMySettings)
OnUninstall:connect(UpdateMySettings)
OnUpdate:connect(UpdateMySettings)

Gui.Settings.Box.Close.MouseButton1Click:connect(function()
	Gui.Settings.Visible = false
	UpdateMySettings()
end)
Gui.Settings.Box.Save.MouseButton1Click:connect(function()
	Gui.Settings.Visible = false
	InstallScript["Internal Stuff"].Var.SJSON.Value = Table2Json(MySettings)
	UpdateMySettings()
end)







-- Documentation Gui (Docs)
local Docs = require(script.doc)
local function GetDocPath(doc)
	local Path = doc.Type .. " "
	if Path == "Text " then Path = "" end
	
	if doc.Type == "Function" then
		local Args = ""
		if doc.Arguments then
			for i = 1,#doc.Arguments do
				local arg = doc.Arguments[i]
				Args = Args .. arg.Name .. ", "
			end
			
			Args = Args:sub(0,#Args - 2)
		end
		
		Path = Path .. "framework:" .. doc.Name .. "(" .. Args .. ")"
	elseif doc.Type == "Callback" then
		local Args = ""
		if doc.Arguments then
			for i = 1,#doc.Arguments do
				local arg = doc.Arguments[i]
				Args = Args .. arg.Name .. ", "
			end
			
			Args = Args:sub(0,#Args - 2)
		end
		
		Path = Path .. "framework." .. doc.Name .. "(" .. Args .. ")"
	elseif doc.Type == "Event" then
		local Args = ""
		if doc.Arguments then
			for i = 1,#doc.Arguments do
				local arg = doc.Arguments[i]
				Args = Args .. arg.Name .. ", "
			end
			
			Args = Args:sub(0,#Args - 2)
		end
		
		Path = Path .. "framework." .. doc.Name .. ":connect(function(" .. Args .. ") end)"
	else
		Path = Path .. doc.Name
	end
	
	-- ex: Function framework:Something(Arg1, Arg2)
	return Path
end

local function UpdateDocsGui()
	Gui.Docs.Box.Info.Visible = false
	Gui.Docs.Box.Main.Visible = true
end
local function OnInfoChanged()
	Gui.Docs.Box.Back.Visible = Gui.Docs.Box.Info.Visible
end

OnInfoChanged()
Gui.Docs.Box.Info.Changed:connect(OnInfoChanged)

Gui.Docs.Box.Close.MouseButton1Click:connect(function()
	Gui.Docs.Visible = false
end)

UpdateDocsGui()
Gui.Docs.Box.Back.MouseButton1Click:connect(UpdateDocsGui)


local DocMenuTemplate1,DocMenuTemplate2 = Gui.Docs.Box.Main.Label:Clone(), Gui.Docs.Box.Main.Item:Clone()
local DocInfoTemplate1,DocInfoTemplate2, DocInfoTemplate3 = Gui.Docs.Box.Info.Label:Clone(), Gui.Docs.Box.Info.Info:Clone(), Gui.Docs.Box.Info.Path:Clone()

local function UpdateDocInfo(doc)
	Gui.Docs.Box.Info:ClearAllChildren()
	Gui.Docs.Box.Info.Visible = true
	Gui.Docs.Box.Main.Visible = false
	
	local function GetInfoPosition()
		local Y = 0
		
		for _,v in pairs(Gui.Docs.Box.Info:GetChildren()) do
			local y = v.Position.Y.Offset + v.Size.Y.Offset
			if y > Y then
				Y = y
			end
		end
		
		return UDim2.new(0,0,0,Y)
	end
	
	
	local Path = DocInfoTemplate3:Clone()
	Path.Position = GetInfoPosition()
	Path.Parent = Gui.Docs.Box.Info
	Path.Text = GetDocPath(doc)
	if not Path.TextFits then
		Path.TextScaled = true
	end
	
	
	-- Info
	local Label = DocInfoTemplate1:Clone()
	Label.Position = GetInfoPosition()
	Label.Parent = Gui.Docs.Box.Info
	Label.Text = "Info"
	
	if not doc.Deprecated then
		Label:ClearAllChildren()
	end
	
	local Text = DocInfoTemplate2:Clone()
	Text.Position = GetInfoPosition()
	Text.Parent = Gui.Docs.Box.Info
	Text.Text = doc.Info
	Text.Size = UDim2.new(1, -40, 0, Text.TextBounds.Y + 25)
	
	if doc.Type == "Text" then return end
	
	-- Restrictions
	if doc.Restrictions then
		local RColor = DocInfoTemplate1.Deprecated.TextColor3
		local Label = DocInfoTemplate1:Clone()
		Label:ClearAllChildren()
		Label.Position = GetInfoPosition()
		Label.Parent = Gui.Docs.Box.Info
		Label.Text = "Restrictions"
		Label.TextColor3 = RColor
		
		local Text = DocInfoTemplate2:Clone()
		Text.Position = GetInfoPosition()
		Text.Parent = Gui.Docs.Box.Info
		Text.Text = doc.Restrictions
		Text.Size = UDim2.new(1, -40, 0, Text.TextBounds.Y + 25)
	end
	
	-- Arguments
	local Label = DocInfoTemplate1:Clone()
	Label:ClearAllChildren()
	Label.Position = GetInfoPosition()
	Label.Parent = Gui.Docs.Box.Info
	Label.Text = "Arguments"
	
	local T
	if doc.Arguments then
		T = ""
		
		for i = 1,#doc.Arguments do
			local arg = doc.Arguments[i]
			
			if T ~= "" then
				T = T .. "\n\n"
			end
			
			T = T  .. arg.Type .. "  " .. arg.Name .. "\n\t\t\t" .. arg.Info
		end
	end
	
	local Text = DocInfoTemplate2:Clone()
	Text.Position = GetInfoPosition()
	Text.Parent = Gui.Docs.Box.Info
	Text.Text = T or "N/A"
	Text.Size = UDim2.new(1, -40, 0, Text.TextBounds.Y + 25)
	
	-- Returns
	if doc.Type == "Function" or doc.Type == "Callback" then
		local Label = DocInfoTemplate1:Clone()
		Label:ClearAllChildren()
		Label.Position = GetInfoPosition()
		Label.Parent = Gui.Docs.Box.Info
		Label.Text = "Returns"
		
		local T
		if doc.Returns then
			T = ""
			
			for i = 1,#doc.Returns do
				local ret = doc.Returns[i]
				
				if T ~= "" then
					T = T .. "\n\n"
				end
				
				T = T  .. ret.Type .. "  " .. ret.Name .. "\n\t\t\t" .. ret.Info
			end
		end
		
		local Text = DocInfoTemplate2:Clone()
		Text.Position = GetInfoPosition()
		Text.Parent = Gui.Docs.Box.Info
		Text.Text = T or "N/A"
		Text.Size = UDim2.new(1, -40, 0, Text.TextBounds.Y + 25)
	end
	
	-- Example
	if doc.Example then
		local Label = DocInfoTemplate1:Clone()
		Label:ClearAllChildren()
		Label.Position = GetInfoPosition()
		Label.Parent = Gui.Docs.Box.Info
		Label.Text = "Example"
		
		local Text = DocInfoTemplate2:Clone()
		Text.Position = GetInfoPosition()
		Text.Parent = Gui.Docs.Box.Info
		Text.Text = doc.Example
		Text.Size = UDim2.new(1, -40, 0, Text.TextBounds.Y + 25)
	end
end

local function UpdateDocMain()
	Gui.Docs.Box.Main:ClearAllChildren()
	
	local function GetMenuPosition()
		local Y = 0
		
		for _,v in pairs(Gui.Docs.Box.Main:GetChildren()) do
			local y = v.Position.Y.Offset + v.Size.Y.Offset
			if y > Y then
				Y = y
			end
		end
		
		return UDim2.new(0,0,0,Y)
	end
	
	for _, api in pairs(Docs) do
		local Label = DocMenuTemplate1:Clone()
		Label.Position = GetMenuPosition()
		Label.Parent = Gui.Docs.Box.Main
		Label.Text = _
		
		for __, doc in pairs(api) do
			local Item = DocMenuTemplate2:Clone()
			Item.Position = GetMenuPosition()
			Item.Parent = Gui.Docs.Box.Main
			Item.Text = GetDocPath(doc)
			Item.Info.MouseButton1Click:connect(function()
				UpdateDocInfo(doc)
				
				Gui.Docs.Box.Info.Visible = true
				Gui.Docs.Box.Main.Visible = false
			end)
			
			if doc.Deprecated then
				Item.TextColor3 = DocInfoTemplate1.Deprecated.TextColor3
			end
		end
	end
end

UpdateDocMain() -- we should only need to call this once, yes?







-- detect if they have the latest version installed, if not let them know to update the plugin
HttpService = game:GetService"HttpService"
function DCRequest(URL, Type, X)
	-- if Type (lower) is "get", X is null
	-- if Type (lower) is "post", X is the table of data to post with PostAsync
	-- automatically, if installed, and connected to DC, the keys are shipped with the request to verify everything

	local DevCircle_Keys = {}
	if InstallScript and InstallScript["Internal Stuff"].Var:findFirstChild("DCK") then
		for _,v in pairs(InstallScript["Internal Stuff"].Var:findFirstChild("DCK"):GetChilldren()) do
			if v:IsA("StringValue") then
				DevCircle_Keys[v.Name] = v.Value
			end
		end
	end

	URL = "https://api.devcircle.net/roblox/" .. URL .. "?JobID=" .. game.JobId .. "&PlaceID=" .. game.PlaceId .. "&CreatorID=" .. CreatorId .. "&PlaceVersion=" .. game.PlaceVersion .. "&FRV=" .. Version
	if Type:lower() == "get" then
		return HttpService:PostAsync(URL, HttpService:JSONEncode(DevCircle_Keys))
	elseif Type:lower() == "post" then
		for _,v in pairs(DevCircle_Keys) do -- add the keys to the request
			X[_] = v
		end
		
		local Data = HttpService:JSONEncode(X)
		return HttpService:PostAsync(URL, Data)
	end
end

spawn(function()
	pcall(function()
		if not HttpService then
			return warn("HttpService.HttpEnabled is false! Some Xeptix Framework features may not work!")
		end
		
		local ver = DCRequest("studio", "post", {tick=tick()})
		if ver:sub(1,8) == "Version:" then
			print("Xeptix Framework Plugin version check response:\n"..ver)
		end
		
		local x, v, id = SeparateString(ver, ":", true)
		if x == "Version" and v then
			ver = v
			if tonumber(id) then
				plugin:SetSetting("CreatorId", tonumber(id))
			end
		else
			return -- website must be down or something
		end
		
		if ver ~= Version then
			Alert("Xeptix Framework Update", "Your version of Xeptix Framework is out of date! To update the framework, please go to the \"Plugins\" Tab, click \"Manage Plugins\", find the Xeptix Framework Plugin and click \"Update\"!\n\nOnce you update the plugin, you MUST re-open this place for the update to take effect!")
		end
	end)
end)






-- Connect to DevCirce gui
Gui.Connect.Box.Close.MouseButton1Click:connect(function()
	Gui.Connect.Visible = false
end)
Gui.ConnectVerify.Box.Close.MouseButton1Click:connect(function()
	Gui.ConnectVerify.Visible = false
end)

Gui.Connect.Box.Verify.MouseButton1Click:connect(function()
	Gui.ConnectVerify.Visible = true
	Gui.Connect.Visible = false
end)

local Cache = {}
Gui.ConnectVerify.Box.Verify.MouseButton1Click:connect(function()
	local Code = Gui.ConnectVerify.Box.TextBox.Text
	local Result = Cache[Code] or DCRequest("connect", "post", {tick=tick(),Code=Code})
	local JSON, Text = nil, ""
	pcall(function() JSON = game.HttpService:JSONDecode(Result) end)
	
	if Result == "failed" then
		Text = "Your code is not valid! Please try again!"
		Cache[Code] = Result
	elseif JSON then
		Text = "Your game is now connected to DevCircle! Congradulations! You may now use Global Leaderboards/Online Server Management!"
		Cache[Code] = Result
		
		Gui.ConnectVerify.Box.Verify:Destroy()
		Gui.ConnectVerify.Box.TextBox:Destroy()
		
		while InstallScript["Internal Stuff"].Var:findFirstChild("DCK") do
			InstallScript["Internal Stuff"].Var.DCK:Destroy()
		end
		
		local DCK = Instance.new("Folder", InstallScript["Internal Stuff"].Var)
		DCK.Name = "DCK"
		local Script = Instance.new("Script", DCK)
		Script.Name = "READ ME! DO NOT SHOW THESE VALUES TO ANYONE!"
		Script.Source = [[-- DO NOT show these values to anyone!
-- If someone puts these values in their framework, they can use your leaderboards, break your server management, and view/change YOUR player data from their game!
-- For your game's saftey, please NEVER show/give these codes to ANYONE, no matter what!

-- We have put in place several security measures to prevent them from breaking your game IF they get your values, however, they are not fullproof, and can possibly be bypassed.
-- Let's just make the world a better place, and keep these codes a secret :)]]
		Script.Disabled = true
		
		local Val = Instance.new("StringValue", DCK)
		Val.Name = "PUB"
		Val.Value = JSON.Public
		
		local Val = Instance.new("StringValue", DCK)
		Val.Name = "PRIV"
		Val.Value = JSON.Private
		
		local Val = Instance.new("StringValue", DCK)
		Val.Name = "GM"
		Val.Value = JSON.Game
		
		updateMenuButtons()
	else
		Text = "An unexpected error occured! We could not validate your code! Please PM Xeptix about this error!"
	end
	
	Gui.ConnectVerify.Box.Result.Text = Text
end)






-- Create the actual plugin
local Mouse = plugin:GetMouse()
local Toolbar = plugin:CreateToolbar("Xeptix Framework Plugin")

local FrameworkButton = Toolbar:CreateButton("Xeptix Framework", "Open the Xeptix Framework Menu, allowing you to install the framework, look at documentation, edit settings, and more!", "")
FrameworkButton.Click:connect(function()
	for _,v in pairs(Gui:GetChildren())do if v.Visible and v ~= Gui.Menu then return end end
	
	Gui.Menu.Visible = not Gui.Menu.Visible
end)

Gui.Menu.Box.Close.MouseButton1Click:connect(function()
	Gui.Menu.Visible = false
end)


-- AutosizeCanvas
pcall(function()
	local function r(p)
		for _,v in pairs(p:GetChildren())do
			r(v)
			if v:IsA("ScrollingFrame") then
				AutosizeCanvas(v)
			end
		end
	end
	
	r(Gui)
	Gui.DescendantAdded:connect(function(Child)
		if Child:IsA("ScrollingFrame") then
			AutosizeCanvas(Child)
		end
	end)
end)


-- We're ready to go!
print("Xeptix Framework Plugin Ready!")
