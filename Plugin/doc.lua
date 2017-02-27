--[[
	File: doc.lua
	Author: Xeptix
	Info: All of the documentation information.
--]]


-- Needs documentation rewrite: ChatAPI and PlayerlistAPI


return { -- Note: ChangeLog is currently not being used.
	["Getting Started"] = {
		{
			Name = "What is Xeptix Framework?",
			Type = "Text",
			Info = "Xeptix Framework is a lightweight and simple tool which adds many libraries, and awesome features. All of this is optional, as the entire framework works as-use, for maximum performance. We also provide efficient global leaderboards, global database, and online server management.\n\nThe framework is designed to reduce the work of developers, by providing many efficient features. All of our features are listed in this documentation."
		},
		{
			Name = "How do I use Xeptix Framework?",
			Type = "Text",
			Info = "Using Xeptix Framework is simple! Just place this line of code at the very top of ALL the scripts you want to use the framework in:\nframework = require(game.ReplicatedStorage:WaitForChild'XeptixFrameworkModule')\n\nAnd just like that your script is functioning with Xeptix Framework!\n\nNow you can use all of the features in this documentation in your script."
		}
	},
	["Creator Interface"] = {
		{
			Name = "How to Use",
			Type = "Text",
			Info = "When the \"CreatorInterfaceEnabled\" Setting is Enabled, while in-game, you can press F4 to open the Creator Interface. The interface allows you to manage the ban list, view/edit player's data, and view game stats (soon). You can also edit the \"Admins\" which is the people who can access the interface.",
		},
	},
	["Core API"] = {
		{
			Name = "IsLocal",
			Type = "Function",
			Info = "Allows you to detect if the current script is on the client or not.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = false,
			Returns = {
				{
					Type = "Boolean",
					Name = "IsLocal",
					Info = "If true, the current script is being ran on the client.",
				}
			},
			Example = false,
		},
		{
			Name = "IsMobile",
			Type = "Function",
			Info = "Allows you to detect if the client is on a mobile device or not.",
			Restrictions = "Will error if ran on the server.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = false,
			Returns = {
				{
					Type = "Boolean",
					Name = "IsMobile",
					Info = "If true, the client is playing on a mobile device.",
				}
			},
			Example = [[local OnMobile = framework:IsMobile()

if OnMobile then
	print("This client is on a mobile device!")
else
	print("This client is not on a mobile device!")
end]],
		},
		{
			Name = "Type",
			Type = "Function",
			Info = "Similar to the \"type\" function ROBLOX supplies, but gives more in-depth info on the type (specifically, in-depth info on the \"userdata\" type)",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Type = "Variant",
					Name = "Variable",
					Info = "You can supply anything for this argument",
				}
			},
			Returns = {
				{
					Type = "String",
					Name = "Type",
					Info = "The type of Variable\n\nHere is a list of all possible types:  string, number, boolean, table, function, vector3, vector2, cframe, color3, brickcolor, udim2, enum, instance, userdata",
				}
			},
			Example = [[print(framework:Type("example")) --> string
print(framework:Type(1337)) --> number
print(framework:Type(Vector3.new(1,3,7))) --> vector3
print(framework:Type(Enum.TextXAlignment.Left)) --> enum
print(framework:Type(workspace.Terrain)) --> instance
print(framework:Type({})) --> table
print(framework:Type(Color3.new(1,0,0))) --> color3]],
		},
		{
			Name = "DecodeJSON",
			Type = "Function",
			Info = "Decodes a JSON string using the HttpService::JSONDecode method, with improved accuracy and error prevention.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Type = "String",
					Name = "JSON",
					Info = "The JSON to Decode",
				}
			},
			Returns = {
				{
					Type = "Table",
					Name = "JSON",
					Info = "The decoded JSON as a table",
				}
			},
			Example = false,
		},
		{
			Name = "JSONDecode",
			Type = "Function",
			Info = "Decodes a JSON string using the HttpService::JSONDecode method, with improved accuracy and error prevention.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Type = "String",
					Name = "JSON",
					Info = "The JSON to Decode",
				}
			},
			Returns = {
				{
					Type = "Table",
					Name = "JSON",
					Info = "The decoded JSON as a table",
				}
			},
			Example = false,
		},
		{
			Name = "EncodeJSON",
			Type = "Function",
			Info = "Encodes a table to a JSON string using the HttpService::JSONEncode method, with improved accuracy and error prevention.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Type = "Table",
					Name = "Table",
					Info = "The table to Encode",
				}
			},
			Returns = {
				{
					Type = "String",
					Name = "JSON",
					Info = "The encoded JSON from the Table",
				}
			},
			Example = false,
		},
		{
			Name = "JSONEncode",
			Type = "Function",
			Info = "Encodes a table to a JSON string using the HttpService::JSONEncode method, with improved accuracy and error prevention.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Type = "Table",
					Name = "Table",
					Info = "The table to Encode",
				}
			},
			Returns = {
				{
					Type = "String",
					Name = "JSON",
					Info = "The encoded JSON from the Table",
				}
			},
			Example = false,
		},
		{
			Name = "OnClose",
			Type = "Event",
			Info = "Fires when the server is closing.",
			Restrictions = "Keep in mind there is a timeout so don't do very long operations.\nDO NOT use game.OnClose with the framework installed, or your game will break!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = false,
			Returns = false,
			Example = [[framework.OnClose:connect(function()
	print("The server is shutting down!")
end)
					
wait(10) -- waiting for more players
					
game.Players:ClearAllChildren()
					
-- everyone has left, the server will shutdown]],
		},
		{
			Name = "Recursive",
			Type = "Function",
			Info = "Calls the function Callback on ALL descendants of Object\nYields until the function is ran on every descendant.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Object",
					Type = "Instance",
					Info = "The object to recurse through",
				},
				{
					Name = "Callback",
					Type = "Function",
					Info = "The function that runs on the descendants\nThe only argument is the descendant (see example for use)",
				}
			},
			Returns = false,
			Example = [[-- Recurse through all descendants of game.Players and print their names in order
print("Printing the names of all descendants of game.Players in order...")
framework:Recursive(game.Players, function(Object)
	print(Object.Name)
end)]],
		},
	},
	["Player Data Storage API"] = {
		{
			Name = "LoadData",
			Type = "Function",
			Info = "Loads the data of a player. Should not be used regularly, to get the loaded data use :GetData(Player) instead. Will error if attempted on the client.",
			Restrictions = "Once the data isn't touched (:Get or :Set isn't used) for 15 minutes, it will automatically unload! This ONLY applies if the player ISN'T in the server.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "Can be the UserID of a player or the Player instance itself",
				}
			},
			Returns = {
				{
					Name = "Data",
					Type = "Save",
					Info = "Returns nil if the load operation fails, otherwise, it returns the save. See :GetData() for documentation on the saves.",
				}
			},
			Example = false,
		},
		{
			Name = "WaitForData",
			Type = "Function",
			Info = "Yields until the data for Player is ready. You must load the data at some point or else this will yield forever.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "Can be the UserID of a player or the Player instance itself",
				}
			},
			Returns = {
				{
					Name = "Data",
					Type = "Save",
					Info = "Returns nil if the load operation fails, otherwise, it returns the save. See :GetData() for documentation on the saves.",
				}
			},
			Example = false,
		},
		{
			Name = "GetData",
			Type = "Function",
			Info = "Gets the data of Player if it has been loaded already. If you are unsure if it has been loaded, use :WaitForData()",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "Can be the UserID of a player or the Player instance itself",
				}
			},
			Returns = {
				{
					Name = "Data",
					Type = "Save",
					Info = "The Player's saved data. Here's the API for Saves:\n\t* :Get(Key)\n\t\t- returns the value for Key, if it doesn't exist it returns nil\n\t* :Set(Key, Value)\n\t\t- sets Value to Key in the save data, will\n\t\t- only works on the server\n\t* :Update(KeyList, UpdateFunction)\n\t\t- sets all of KeyList to UpdateFunction(oldValue)\n\t\t- only works on the server\n\t* :Save()\n\t\t- forces the data to save\n\t\t- should not be done regularly due to roblox's restrictions\n\t\t- only works on the server\n\t* :GetKeys()\n\t\t- gets all of the save data\n\t\t- example: {Cash = 1337, XP = 100, AnotherValueISaved = true}\n\t* .userId\n\t\t- the UserID of who the save belongs to\n\t* .lastSaved\n\t\t- a timestamp of when the data was last saved",
				}
			},
			Example = false,
		},
		{
			Name = "KeyChanged",
			Type = "Event",
			Info = "Fires when a key is changed (if the save belongs to someone in the server).",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player whos save the key belongs to",
				},
				{
					Name = "Key",
					Type = "String",
					Info = "The key that was changed",
				},
				{
					Name = "OldValue",
					Type = "Variant",
					Info = "The old value for key",
				},
				{
					Name = "NewValue",
					Type = "Variant",
					Info = "The new value for key",
				}
			},
			Returns = false,
			Example = false,
		},		
	},
	["Server/Client Communication"] = {
		{
			Name = "AddEvent",
			Type = "Function",
			Info = "Adds a module to the internal event storage. Similar to parenting the module to the Events folder inside of the XeptixFramework Module. If on server, allows the module to be ran using :FireServer(), If on client, allows the module to be ran using :FireClient().",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Module",
					Type = "Instance",
					Info = "The module to add",
				}
			},
			Returns = false,
			Example = [[-- ExampleModule, a ModuleScript parented to ReplicatedStorage:
return function(Player, Message)
	print(Player.Name .. " fired the server! Their message: " .. Message)
end

-- On the Server:
framework:AddEvent(game.ReplicatedStorage.ExampleModule)

-- On the Client:
framework:FireServer("ExampleModule", "this is a message") --> Xeptix fired the server! Their message: this is a message
framework:FireServer("ExampleModule", "sup") --> Xeptix fired the server! Their message: sup]],
		},
		{
			Name = "AddFunction",
			Type = "Function",
			Info = "Adds a module to the internal function storage. Similar to parenting the module to the Functions folder inside of the XeptixFramework Module. If on server, allows the module to be ran using :InvokeServer(), If on client, allows the module to be ran using :InvokeClient().",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Module",
					Type = "Instance",
					Info = "The module to add",
				}
			},
			Returns = false,
			Example = [[-- ExampleModule, a ModuleScript parented to ReplicatedStorage:
return function(Player, Message)
	-- now we're going to return the string for the client to print
	return Player.Name .. " invoked the server! Their message: " .. Message
end

-- On the Server:
framework:AddEvent(game.ReplicatedStorage.ExampleModule)

-- On the Client:
local msg1 = framework:InvokeServer("ExampleModule", "this is a message")
local msg2 = framework:InvokeServer("ExampleModule", "sup")

print(msg1) --> Xeptix invoked the server! Their message: this is a message
print(msg2) --> Xeptix invoked the server! Their message: sup]],
		},
		{
			Name = "FireServer",
			Type = "Function",
			Info = "Fires a module on the server. Will throw an error if ran on server.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "ModuleName",
					Type = "String",
					Info = "The name of the Module on the server to run",
				},
				{
					Name = "...",
					Type = "",
					Info = "The arguments for the Module",
				}
			},
			Returns = false,
			Example = [[framework:FireServer("ExampleModule", "example", 1337)]],
		},
		{
			Name = "FireClient",
			Type = "Function",
			Info = "Fires a module on a players client. Can be called from other clients.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to run the Module on",
				},
				{
					Name = "ModuleName",
					Type = "String",
					Info = "The name of the Module on the clients to run",
				},
				{
					Name = "...",
					Type = "",
					Info = "The arguments for the Module",
				}
			},
			Returns = false,
			Example = [[framework:FireClient(Player, "ExampleModule", "example", 1337)]],
		},
		{
			Name = "FireAllClients",
			Type = "Function",
			Info = "Fires a module on a players client. Can be called from other clients.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "ModuleName",
					Type = "String",
					Info = "The name of the Module on the clients to run",
				},
				{
					Name = "...",
					Type = "",
					Info = "The arguments for the Module",
				}
			},
			Returns = false,
			Example = [[framework:FireAllClients("ExampleModule", "example", 1337)]],
		},
		{
			Name = "InvokeServer",
			Type = "Function",
			Info = "Invokes a module on the server. Will throw an error if ran on server.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "ModuleName",
					Type = "String",
					Info = "The name of the Module on the server to run",
				},
				{
					Name = "...",
					Type = "",
					Info = "The arguments for the Module",
				}
			},
			Returns = false,
			Example = [[local x = framework:InvokeServer("ExampleModule", "example", 1337)]],
		},
		{
			Name = "InvokeClient",
			Type = "Function",
			Info = "Invokes a module on a players client. Can be called from other clients.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to run the Module on",
				},
				{
					Name = "ModuleName",
					Type = "String",
					Info = "The name of the Module on the clients to run",
				},
				{
					Name = "...",
					Type = "",
					Info = "The arguments for the Module",
				}
			},
			Returns = false,
			Example = [[local x = framework:InvokeClient(Player, "ExampleModule", "example", 1337)]],
		},
		{
			Name = "InvokeAllClients",
			Type = "Function",
			Info = "Invokes a module on a players client. Can be called from other clients.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "ModuleName",
					Type = "String",
					Info = "The name of the Module on the clients to run",
				},
				{
					Name = "...",
					Type = "",
					Info = "The arguments for the Module",
				}
			},
			Returns = false,
			Example = [[local x = framework:InvokeAllClients("ExampleModule", "example", 1337)]],
		},
	},
	["Badge API"] = {
		{
			Name = "AwardBadge",
			Type = "Function",
			Info = "Awards BadgeID to UserID only if they do not already have the badge. The user must be in the game in order for the badge to be awarded. When awarded, framework.BadgeAwarded is fired.",
			Restrictions = "* This function is only available on the server! Calling it from the client will result in an error!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "UserID",
					Type = "Number",
					Info = "The UserID of the player to award the badge to",
				},
				{
					Name = "BadgeID",
					Type = "Number",
					Info = "The ID of the badge to award",
				},
			},
			Returns = false,
			Example = false,
		},
		{
			Name = "HasBadge",
			Type = "Function",
			Info = "Checks if UserID has already been awarded BadgeID. Also works for any item on the site, including clothes, hats, models, gamepasses, etc.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "UserID",
					Type = "Number",
					Info = "The UserID of the player to check for BadgeID",
				},
				{
					Name = "BadgeID",
					Type = "Number",
					Info = "The ID of the badge to check for",
				},
			},
			Returns = {
				{
					Name = "HasBadge",
					Type = "Boolean",
					Info = "true if they have the badge, false otherwise",
				},
			},
			Example = false,
		},
		{
			Name = "BadgeAwarded",
			Type = "Event",
			Info = "Fires when a badge is awarded in the server. Only fires if framework:AwardBadge was used. Only fires if Player got BadgeID for the first time.",
			Restrictions = "* This event is only available on the server! It will not fire on the client!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "UserID",
					Type = "Number",
					Info = "The UserID of the player who earned the badge",
				},
				{
					Name = "BadgeID",
					Type = "Number",
					Info = "The ID of the badge they earned",
				},
			},
			Returns = false,
			Example = [[framework.BadgeAwarded:connect(function(Player, BadgeID)
	print(Player.Name .. " got badge: " .. BadgeID) --> Player1 got badge: 1337
end)

print("Awarding badge...") --> Awarding badge...

local ID = game.Players.Player1.userId
framework:AwardBadge(ID, 1337)]],
		},
	},
	["Ban API"] = {
		{
			Name = "Kick",
			Type = "Function",
			Info = "Kicks a Player from the server. If the client attempts to use this function, and the \"ClientCanUseBanAPI\" setting is false, then calling this function will result in an error.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to kick. They MUST be in the server!",
				},
				{
					Name = "Reason",
					Type = "String",
					Info = "The reason for kicking them (optional). If supplied, Player will be able to read why they were kicked.",
				},
			},
			Returns = false,
			Example = false,
		},
		{
			Name = "Ban",
			Type = "Function",
			Info = "Kicks a Player from the server. Bans Player from all servers for (x) hours. If the client attempts to use this function, and the \"ClientCanUseBanAPI\" setting is false, then calling this function will result in an error",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to ban. If they are not in the server, use their UserID instead!",
				},
				{
					Name = "Reason",
					Type = "String",
					Info = "The reason for banning them (optional). If supplied, Player will be able to read why they try and enter the game.",
				},
				{
					Name = "Duration",
					Type = "Number",
					Info = "The number of hours they are banned. If not supplied, or nil is supplied, they will be banned for life. Examples:	0.5 = a half hour, 1 = an hour, 24 = a day, etc",
				},
			},
			Returns = false,
			Example = false,
		},
		{
			Name = "Unban",
			Type = "Function",
			Info = "Removes any existing ban on the user. If the client attempts to use this function, and the \"ClientCanUseBanAPI\" setting is false, then calling this function will result in an error",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "UserID",
					Type = "Number",
					Info = "The UserID of the player to unban",
				},
			},
			Returns = false,
			Example = false,
		},
		{
			Name = "GetBanHistory",
			Type = "Function",
			Info = "Gets the ban history for Player.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to get the ban history of",
				},
			},
			Returns = {
				{
					Name = "BanHistory",
					Type = "Table",
					Info = "The ban history for Player. The table goes as follows:\n\tType = [0 = unban, 1 = ban, 2 = kick]\n\tTimestamp = [the timestamp of when the player was kicked/banned/unbanned]\n\tReason = [the reason for banning/kicking them] [a blank string if Type = 0]\n\tDuration = [the duration of the ban] [0 if Type = 0 or 2]",
				},
			},
			Example = false,
		},
	},
	["Global Leaderboard API"] = {
		{
			Name = "GetLeaderboard",
			Type = "Function",
			Info = "Gets the leaderboard for Key. Uses the integrated PlayerDataStore for automatic updates. Possibility that it will yeild (if the Leaderboard for Key is being made). Automatically updates every 5 minutes.",
			Restrictions = "Your place must be connected to DevCircle in order to use the Leaderboard API.\n\nCurrently, we only fetch the top 1000 players, but you can limit how many to display up to this amount.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Key",
					Type = "String",
					Info = "This must be a key within the save for the player. If you do not use Xeptix Framework's player data storage, this leaderboard will not work."
				},
				{
					Name = "SortOrder",
					Type = "Number",
					Info = "The order in which to sort the leaderboard. 1 is Greatest to Least, 2 is Least to Greatest.",
				},
				{
					Name = "Start",
					Type = "Number",
					Info = "The position in the leaderboard to start at. By default this is 0.",
				},
				{
					Name = "Limit",
					Type = "Number",
					Info = "The total number of leaderboard entries to fetch. By default this is all 1000 entries, and is also capped at 1000 entries.",
				},
			},
			Returns = {
				{
					Name = "Leaderboard",
					Type = "Table",
					Info = "The leaderboard table. Goes as follows:\n1 = Player\n2 = Player\n3 = Player\netc\n\nThe 'Player' table goes as follows:\nPosition = The leaderboard position of the player\nName     = The name of the player\nUserID   = The userId of the player\nValue    = The value of Key (for example, if Key was \"Cash\" and they had $100, this would be 100)"
				}
			},
			Example = [[local Leaderboard = framework:GetLeaderboard("Kills", 1, 0, 10)

print("Got top 10 kills!") -->Got top 10 kills!

for Position = 1, #Leaderboard do
	local Player = Leaderboard[Position]

	print(Player.Name .. " is #" .. Player.Position .. " on the kills leaderboard, with " .. Player.Value .. " kills!") -->Soluke is #1 on the kills leaderboard, with 108 kills!
end]],
		},
		{
			Name = "GetLeaderboardPositionForPlayer",
			Type = "Function",
			Info = "Gets the Position number for Player on leaderboard Key. Will return 0 if they are not on the leaderboard.",
			Restrictions = "Your place must be connected to DevCircle in order to use the Leaderboard API.\n\nIf their position in the leaderboard is over 250, this function will say they are #251 no matter what. This is because we only fetch the top 250 players!\n\nThis was deprecated in v2 due to the 250 leaderboard size limit, however it still works.",
			Deprecated = true,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Key",
					Type = "String",
					Info = "This must be a key within the save for the player. If you do not use Xeptix Framework's player data storage, this leaderboard will not work."
				},
				{
					Name = "Player",
					Type = "Instance",
					Info = "The Player to find on the leaderboard. Can be the UserID of the player.",
				}
			},
			Returns = {
				{
					Name = "Position",
					Type = "Number",
					Info = "The position of the Player on the leaderboard. Will be 0 if they aren't on the leaderboard."
				},
				{
					Name = "Value",
					Type = "Number",
					Info = "Their score on the leaderboard. Will be 0 if they aren't on the leaderboard."
				}
			},
			Example = [[local Player1 = 6115561 -- TooMuchGibberish's UserID
local Player2 = game.Players.Xeptix

local Position1, Score1 = framework:GetLeaderboardPositionForPlayer("Level", Player1)
local Position2, Score2 = framework:GetLeaderboardPositionForPlayer("Level", Player2)

print("TooMuchGibberish is #" .. Position1 .. " on Level leaderboard, they are level " .. Score1 .. "!") -->TooMuchGibberish is #51 on Level leaderboard, they are level 2!
print("Xeptix is #" .. Position2 .. " on Level leaderboard, they are level " .. Score2 .. "!") -->Xeptix is #4 on Level leaderboard, they are level 33!]],
		},
		{
			Name = "LeaderboardUpdated",
			Type = "Event",
			Info = "Fires every time a leaderboard is updated",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Key",
					Type = "String",
					Info = "The key of the leaderboard that updated.",
				},
			},
			Returns = false,
			Example = [[framework.LeaderboardUpdated:connect(function(Key)
	print("The leaderboard for key '" .. Key .. "' has updated!") -->The leaderboard for key 'Cash' has updated!

	-- update the leaderboard gui (or whatever displays the leaderboard)
end)]],
		},
	},
	["Developer Product API"] = {
		{
			Name = "GetPurchaseHistory",
			Type = "Function",
			Info = "Gets the purchase history of Player. The PurchaseHistory table is in order from 1st purchase to last.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to get the purchase history for.",
				}
			},
			Returns = {
				{
					Name = "PurchaseHistory",
					Type = "Table",
					Info = "The PurchaseHistory table, which goes as follows (example):\n1 = purchase\n2 = purchase\n3 = purchase\n\nThe 'purchase' table goes as follows:\nProductId 	  = [the id of the product purchased]\nTimestamp 	  = [a timestamp of when the purchase completed]\nCurrencyType  = [\"robux\" or \"tix\"]\nCurrencySpent = [a number of how much of CurrencyType was spent]\nReceipt 	  = [the Receipt table]",
				}
			},
			Example = false,
		},
		{
			Name = "PromptProductPurchase",
			Type = "Function",
			Info = "Prompts Player to purchase ProductId.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to prompt.",
				},
				{
					Name = "ProductId",
					Type = "Number",
					Info = "The ID of the product to prompt for purchase.",
				}
			},
			Returns = false,
			Example = false,
		},
	},
	["String API"] = {
		{
			Name = "SeparateString",
			Type = "Function",
			Info = "Allows you to separate a string into parts based on a key separator. Gives you the option to get the parts as a table or as individual variables.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "String",
					Type = "String",
					Info = "The string you'd like to separate.",
				},
				{
					Name = "Separator",
					Type = "String",
					Info = "The separator (single character)",
				},
				{
					Name = "UnpackResults",
					Type = "Boolean",
					Info = "If supplied, the results will be returned as individual variables. Iif not supplied, the results will be returned as a table.",
				}
			},
			Returns = {
				{
					Name = "Results",
					Type = "Variant",
					Info = "If not UnpackResults, Results is a table. If UnpackResults, Results is the first part, and then the other parts are returned in order.",
				}
			},
			Example = [[local Str = "This, is an, example!"
local Parts = framework:SeparateString(Str, ",")
					
for i = 1, #Parts do
	print(Parts[i]) -->This
	                --> is an
	                --> example!
end]],
		},
	},
	["Number"] = {
		{
			Name = "RoundNumber",
			Type = "Function",
			Info = "Rounds a number to the nearest whole number.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Number",
					Type = "Number",
					Info = "The number you'd like to round.",
				}
			},
			Returns = {
				{
					Name = "WholeNumber",
					Type = "Number",
					Info = "The rounded number.",
				}
			},
			Example = [[print(4 .. ": " .. framework:RoundNumber(4)) -->4
print(4.8 .. ": " .. framework:RoundNumber(4.8)) -->5
print(4.5 .. ": " .. framework:RoundNumber(4.5)) -->5
print(4.4 .. ": " .. framework:RoundNumber(4.4)) -->4]],
		},
		{
			Name = "NumberWithCommas",
			Type = "Function",
			Info = "Formats a number, adding commas.",
			Restrictions = "* This was deprecated in v2.1, and is being replaced by framework:FormatNumber(), however this function does still work!",
			Deprecated = true,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Number",
					Type = "Number",
					Info = "The number you'd like to format.",
				}
			},
			Returns = {
				{
					Name = "FormattedNumber",
					Type = "String",
					Info = "The formatted number.",
				}
			},
			Example = [[print(framework:NumberWithCommas(4)) -->4
print(framework:NumberWithCommas(42)) -->42
print(framework:NumberWithCommas(420)) -->420
print(framework:NumberWithCommas(4200)) -->4,200
print(framework:NumberWithCommas(42000)) -->42,000
print(framework:NumberWithCommas(123456)) -->123,456
print(framework:NumberWithCommas(123456789)) -->123,456,789]],
		},
		{
			Name = "FormatNumber",
			Type = "Function",
			Info = "Reformats a number into a readable string format.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Number",
					Type = "Number",
					Info = "The number you'd like to format.",
				},
				{
					Name = "AllowDecimals",
					Type = "Boolean",
					Info = "If true the number with be formatted with decimals, if false it will be rounded before formatted.",
				}
			},
			Returns = {
				{
					Name = "FormattedNumber",
					Type = "String",
					Info = "The formatted number.",
				}
			},
			Example = [[print(framework:FormatNumber(4)) -->4
print(framework:FormatNumber(42.69)) -->42
print(framework:FormatNumber(420.69,true)) -->420.69
print(framework:FormatNumber(4200, true)) -->4,200.0
print(framework:FormatNumber(42000.25125)) -->42,000
print(framework:FormatNumber(123456.512531, true)) -->123,456.512531
print(framework:FormatNumber(123456789)) -->123,456,789]],
		},
		{
			Name = "AbbreviateNumber",
			Type = "Function",
			Info = "Abbreviates a number to make it shorter.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Number",
					Type = "Number",
					Info = "The number you'd like to abbreviate.",
				}
			},
			Returns = {
				{
					Name = "Abbreviation",
					Type = "String",
					Info = "The abbreviated number.",
				}
			},
			Example = [[print(framework:AbbreviateNumber(5316749)) -->5M+
print(framework:AbbreviateNumber(531)) -->531
print(framework:AbbreviateNumber(5316)) -->5K+]],
		},
	},
	["Table API"] = {
		{
			Name = "ShuffleTable",
			Type = "Function",
			Info = "Randomizes the table. Supports both numerical and non-numerical indexes/values.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Table",
					Type = "Table",
					Info = "The table you'd like to shuffle.",
				}
			},
			Returns = {
				{
					Name = "Shuffled",
					Type = "Table",
					Info = "The shuffled table.",
				}
			},
			Example = [[local Table = {1, 2, 3, 4}
local Shuffled = framework:ShuffleTable(Table)

print("Before Shuffle:")
for _, v in pairs(Table)  do -- in order
	print("Table[" .. _ .. "] = " .. v)
end

print("After Shuffle:")
for _, v in pairs(Shuffled)  do -- in order
	print("Shuffled[" .. _ .. "] = " .. v)
end]],
		},
		{
			Name = "DuplicateTable",
			Type = "Function",
			Info = "Duplicates the table. Supports both numerical and non-numerical indexes/values.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Table",
					Type = "Table",
					Info = "The table you'd like to duplicate.",
				}
			},
			Returns = {
				{
					Name = "Duplicate",
					Type = "Table",
					Info = "The duplicated table.",
				}
			},
			Example = [[local Table = {"how", "are", "you", "today?"}
local Duplicate = framework:DuplicateTable(Table)

for _,v in pairs(Table) do -- in order
	print("Table[" .. _ .. "] = " .. v)
end

for _,v in pairs(Duplicate) do -- in order
	print("Duplicate[" .. _ .. "] = " .. v)
end]],
		},
		{
			Name = "RemoveIndexFromTable",
			Type = "Function",
			Info = "Removes an index the table. Supports both numerical and non-numerical indexes/values.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Table",
					Type = "Table",
					Info = "The table you'd like to remove the index from.",
				},
				{
					Name = "Index",
					Type = "Variant",
					Info = "The index to remove.",
				}
			},
			Returns = {
				{
					Name = "Table",
					Type = "Table",
					Info = "The new version of Table, without Index.",
				}
			},
			Example = [[local Table = {
	[2] = "Sup",
	[4] = "Dude",
	[6] = "How",
	[8] = "Are",
	[10] = "You",
	Blah = "Today?"
}
local New = framework:RemoveIndexFromTable(Table, 2)

for _,v in pairs(Table) do -- in order
	print("Table[" .. _ .. "] = " .. v)
end

for _,v in pairs(New) do -- in order
	print("New[" .. _ .. "] = " .. v)
end]],
		},
		{
			Name = "IndexCount",
			Type = "Function",
			Info = "Returns the number of indexes in Table. Similar to doing \"#Table\", except this function supports non-numerical indexes.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Table",
					Type = "Table",
					Info = "The table to count the indexes of.",
				}
			},
			Returns = {
				{
					Name = "Count",
					Type = "Number",
					Info = "The number of indexes in Table.",
				}
			},
			Example = [[local Table = {Sup = 12, 35, 12, 1, 2, Hey = 5} -- 6 indexes
Table[workspace] = 1337 -- add workspace index to the table, now 7 indexes

print(framework:IndexCount(Table)) -->7"
}
local New = framework:RemoveIndexFromTable(Table, 2)

for _,v in pairs(Table) do -- in order
	print("Table[" .. _ .. "] = " .. v)
end

for _,v in pairs(New) do -- in order
	print("New[" .. _ .. "] = " .. v)
end]],
		},
		{
			Name = "ValueExistsInTable",
			Type = "Function",
			Info = "Checks Table for Value.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Table",
					Type = "Table",
					Info = "The table to check.",
				},
				{
					Name = "Value",
					Type = "Variant",
					Info = "The value to find.",
				}
			},
			Returns = {
				{
					Name = "Exists",
					Type = "Boolean",
					Info = "true if Value is in Table, false otherwise.",
				}
			},
			Example = [[local t = {'sup', 'hey'}

print(framework:ValueExistsInTable(t, 'hey')) -->true
print(framework:ValueExistsInTable(t, 'hello')) -->false]],
		},
	},
	["Player API"] = {
		{
			Name = "PlayerFromUserID",
			Type = "Function",
			Info = "Gets a player from their userId. The player must be in-game for this function to work.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "UserID",
					Type = "Number",
					Info = "The UserID of the player",
				}
			},
			Returns = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player who's userId matches UserID. If no player is found, nil is returned.",
				}
			},
			Example = false,
		},
		{
			Name = "UsernameFromUserID",
			Type = "Function",
			Info = "Gets a player's username from their userId. The player does not have to be in-game for this function to work. As of v1.0.500, this now works on Guests too!",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "UserID",
					Type = "Number",
					Info = "The UserID of the player.",
				}
			},
			Returns = {
				{
					Name = "Username",
					Type = "String",
					Info = "The Username of the player or nil if the account doesn't exist.",
				}
			},
			Example = [[print(framework:UsernameFromUserID(6115561)) -->TooMuchGibberish]],
		},
		{
			Name = "UserIDFromUsername",
			Type = "Function",
			Info = "Gets a player's UserID from their username. The player does not have to be in-game for this function to work.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Username",
					Type = "String",
					Info = "The Username of the player.",
				}
			},
			Returns = {
				{
					Name = "UserID",
					Type = "Number",
					Info = "The UserID of the player or nil if the account doesn't exist.",
				}
			},
			Example = [[print(framework:UsernameFromUserID("TooMuchGibberish")) -->6115561]],
		},
		{
			Name = "GetSessionHistory",
			Type = "Function",
			Info = "[Removed in v2]",
			Restrictions = false,
			Deprecated = true,
			ChangeLog = {
				["v2.0.3"] = "Removed the function."
			},
			Arguments = false,
			Returns = false,
			Example = false,
		},
		{
			Name = "PlayerAdded",
			Type = "Event",
			Info = "Fires when a player enters the game.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player that joined.",
				}
			},
			Returns = false,
			Example = [[framework.PlayerAdded:connect(function(Player)
	print(Player.Name .. " has entered the game! Timestamp: " .. tick())
end)]],
		},
		{
			Name = "SafePlayerAdded",
			Type = "Callback",
			Info = "Fires when a player enters the game, and on every player already in the game.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Callback",
					Type = "Function",
					Info = "The function to run when they join. The only argument is the player that joined.",
				}
			},
			Returns = {
				{
					Name = "Disconnect",
					Type = "Function",
					Info = "When this function is called, Callback will no longer be called when a player enters. Can only be called once.",
				}
			},
			Example = [[-- Player1 joins the game
wait(5)
-- Player2 joins the game
wait(12)
framework.SafePlayerAdded(function(Player)
	print(Player.Name .. " has entered the game! Timestamp: " .. tick())
end)
					
wait(2)
					
-- Player3 joins the game]],
		},
		{
			Name = "PlayerRemoving",
			Type = "Event",
			Info = "Fires when a player is leaving the game.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player leaving.",
				}
			},
			Returns = false,
			Example = [[framework.PlayerRemoving:connect(function(Player)
	print(Player.Name .. " is leaving the game! Timestamp: " .. tick())
end)]],
		},
		{
			Name = "PlayerRemoved",
			Type = "Event",
			Info = "Fires when a player has left the game.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player that left.",
				}
			},
			Returns = false,
			Example = [[framework.PlayerRemoved:connect(function(Player)
	print(Player.Name .. " has left the game! Timestamp: " .. tick())
end)]],
		},
	},
	["Part API"] = {
		{
			Name = "TweenPart",
			Type = "Function",
			Info = "[N/A]",
			Restrictions = "* This was removed in v2, and was replaced with :TweenPartPosition. Please use it instead.",
			Deprecated = true,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Part",
					Type = "Instance",
					Info = "The part to tween",
				},
				{
					Name = "Position",
					Type = "Vector3",
					Info = "The position to tween to",
				},
				{
					Name = "Direction",
					Type = "Enum",
					Info = "The direction enum, by default this is \"Out\".",
				},
				{
					Name = "Style",
					Type = "Enum",
					Info = "The style enum, by default this is \"Quad\".",
				},
				{
					Name = "Time",
					Type = "Number",
					Info = "The duration of tweening, by default this is 3 seconds.",
				}
			},
			Returns = false,
			Example = false,
		},
		{
			Name = "TweenPartPosition",
			Type = "Function",
			Info = "Tweens a parts position. Works very similar as :TweenPosition does for guis.\n\nframework:TweenPart() is now deprecated and subject to removal! Please use this instead!",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Part",
					Type = "Instance",
					Info = "The part to tween",
				},
				{
					Name = "Position",
					Type = "Vector3",
					Info = "The position to tween to",
				},
				{
					Name = "Direction",
					Type = "Enum",
					Info = "The direction enum, by default this is \"Out\".",
				},
				{
					Name = "Style",
					Type = "Enum",
					Info = "The style enum, by default this is \"Quad\".",
				},
				{
					Name = "Time",
					Type = "Number",
					Info = "The duration of tweening, by default this is 3 seconds.",
				}
			},
			Returns = false,
			Example = [[local Part = workspace.Part
local Pos = Part.Position + Vector3.new(25, 25, 0)
					
framework:TweenPartPosition(Part, Pos, "Out", "Quad", 0.5)]],
		},
		{
			Name = "TweenPartSize",
			Type = "Function",
			Info = "Tweens a parts size. Works very similar as :TweenSize does for guis.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Part",
					Type = "Instance",
					Info = "The part to tween",
				},
				{
					Name = "Size",
					Type = "Vector3",
					Info = "The size to tween to",
				},
				{
					Name = "Direction",
					Type = "Enum",
					Info = "The direction enum, by default this is \"Out\".",
				},
				{
					Name = "Style",
					Type = "Enum",
					Info = "The style enum, by default this is \"Quad\".",
				},
				{
					Name = "Time",
					Type = "Number",
					Info = "The duration of tweening, by default this is 3 seconds.",
				}
			},
			Returns = false,
			Example = [[local Part = workspace.Part
local Size = Part.Size + Vector3.new(25, 25, 0)

framework:TweenPartSize(Part, Size, "Out", "Bounce", 0.5)]],
		},
		{
			Name = "GetCFrame",
			Type = "Function",
			Info = "Gets the CFrame of Object. Works on both Models and Parts.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Object",
					Type = "Instance",
					Info = "The model or part to get the cframe of.",
				}
			},
			Returns = {
				{
					Name = "CFrame",
					Type = "CFrame",
					Info = "The CFrame of the part or model",
				}
			},
			Example = [[print(framework:GetCFrame(workspace.Model)) -->0, 0, 0, 0.411982268, 0.0587266423, 0.909297407, -0.681242704, -0.64287281, 0.35017547, 0.605127215, -0.763718367, -0.224845082]],
		},
		{
			Name = "GetRotation",
			Type = "Function",
			Info = "Gets the Rotation of Object. Works on both Models and Parts.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Object",
					Type = "Instance",
					Info = "The model or part to get the rotation of.",
				}
			},
			Returns = {
				{
					Name = "X",
					Type = "Number",
					Info = "The X Rotation of the Part or Model.",
				},
				{
					Name = "Y",
					Type = "Number",
					Info = "The Y Rotation of the Part or Model.",
				},
				{
					Name = "Z",
					Type = "Number",
					Info = "The Z Rotation of the Part or Model.",
				}
			},
			Example = [[local x, y, z = framework:GetRotation(workspace.Model)
print(x, y, z)]],
		},
		{
			Name = "SetCFrame",
			Type = "Function",
			Info = "Sets the CFrame of Object to CFrame. Works on both Models and Parts.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Object",
					Type = "Instance",
					Info = "The model or part to set the cframe of.",
				},
				{
					Name = "CFrame",
					Type = "CFrame",
					Info = "The new CFrame for Object",
				},
				{
					Name = "NewFrame",
					Type = "Boolean",
					Info = "MUST SUPPLY. If true, it will set a new CFrame. If false, it will add to the previous CFrame.",
				}
			},
			Returns = false,
			Example = [[framework:SetCFrame(workspace.Model, CFrame.new(100,420,0), true)]],
		},
		{
			Name = "SetRotation",
			Type = "Function",
			Info = "Sets the Rotation of Object to Rotation. Works on both Models and Parts.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Object",
					Type = "Instance",
					Info = "The model or part to set the rotation of.",
				},
				{
					Name = "Rotation",
					Type = "CFrame",
					Info = "The new Rotation for Object",
				},
				{
					Name = "Increment",
					Type = "Number",
					Info = "OPTIONAL. If true, it will add Rotation to the current Rotation.",
				}
			},
			Returns = false,
			Example = [[framework:SetRotation(workspace.Model, CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)))
					
-- now let's add 45 more degrees to the rotation, making it 90 total
framework:SetRotation(workspace.Model, CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), true)]],
		},
	},
	["Gui API"] = {
		{
			Name = "AutosizeCanvas",
			Type = "Function",
			Info = "Allows a ScrollingFrame to automatically adjust its canvas size to fit all children. Gives you the option to add padding.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "ScrollingFrame",
					Type = "Instance",
					Info = "The ScrollingFrame.",
				},
				{
					Name = "Padding",
					Type = "Number",
					Info = "By default padding is 0, adds extra space to the canvas.",
				}
			},
			Returns = false,
			Example = false,
		},
		{
			Name = "Gui3d",
			Type = "Function",
			Info = "Allows you to place a pesudo-3d gui below a gui object.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "GuiObject",
					Type = "Instance",
					Info = "The gui to show the part under",
				},
				{
					Name = "Part",
					Type = "Instance",
					Info = "The part to show.",
				},
				{
					Name = "RotateGui",
					Type = "Boolean",
					Info = "If supplied, the gui will automatically rotate.",
				}
			},
			Returns = {
				{
					Name = "3dController",
					Type = "Table",
					Info = "* 3dController:SetActive(boolean active)\n	- Toggles whether or not the 3D Object should be shown or not\n* 3dController:SetCFrame(CoordinateFrame Offset)\n	- Sets a CFrame rotation and offset from the location its trying to place the 3D Model.\n	- Note that by default, it sets the CFrame a blank CFrame.new().\n* 3dController:End()\n	- Effectively Removes the model and disconnects its movement events.\n* 3dController.Object3D\n	- The current model being used."
				}
			},
			Example = false,
		},
	},
	["Collision API"] = {
		{
			Name = "IsColliding",
			Type = "Function",
			Info = "Checks if Object is colliding with SecondObject.\nOptional argument \"IgnoreList\" if you want to exclude some objects.\nWorks on Models, Parts, and Guis!",
			Restrictions = "If you supply a Gui for Object, you must do the same for SecondObject (and vice-versa) you can not detect if a part/model is colliding with a gui.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Object",
					Type = "Instance",
					Info = "The first object. Can be a Model, Part, or Gui. If SecondObject is a Gui, this must also be a Gui.",
				},
				{
					Name = "SecondObject",
					Type = "Instance",
					Info = "The second object. Can be a Model, Part, or Gui. If Object is a Gui, this must also be a Gui.",
				},
				{
					Name = "IgnoreList",
					Type = "Table",
					Info = "A list of objects the collision detection will ignore. Optional, you don't have to supply anything for this.",
				}
			},
			Returns = {
				{
					Name = "IsColliding",
					Type = "Boolean",
					Info = "true if they are colliding with eachother, false otherwise",
				},
			},
			Example = [[print(framework:IsColliding(ScreenGui.Frame, ScreenGui.Frame2)) -->true
print(framework:IsColliding(workspace.Model, workspace.BasePlate)) -->true
print(framework:IsColliding(workspace.BasePlate, workspace.Part)) -->false]],
		},
		{
			Name = "GetColliding",
			Type = "Function",
			Info = "Gets all of the objects colliding with Object.\nOptional argument \"IgnoreList\" if you want to exclude some objects.\nWorks on Models, Parts, and Guis!",
			Restrictions = "If you supply a Gui for Object, you must do the same for SecondObject (and vice-versa) you can not detect if a part/model is colliding with a gui.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Object",
					Type = "Instance",
					Info = "The object. Can be a Model, Part, or Gui.",
				},
				{
					Name = "IgnoreList",
					Type = "Table",
					Info = "A list of objects the collision detection will ignore. Optional, you don't have to supply anything for this.",
				}
			},
			Returns = {
				{
					Name = "Colliding",
					Type = "Table",
					Info = "A list of all the things colliding with Object.",
				},
			},
			Example = [[local Model = workspace.Model -- inside is 2 parts named "Part" and 1 part named "ModelPart"
local Part = workspace.BasePlate
local Gui = ScreenGui.Frame -- inside is a button named "TextButton"

local CollidingWithModel = framework:GetColliding(Model)
local CollidingWithPart = framework:GetColliding(Part)
local CollidingWithGui = framework:GetColliding(Gui)

print("Colliding w/ Model:")
for _,v in pairs(CollidingWithModel) do
	print(v)
end

print("\nColliding w/ Part:")
for _,v in pairs(CollidingWithModel) do
	print(v)
end

print("\nColliding w/ Gui:")
for _,v in pairs(CollidingWithModel) do
	print(v)
end]],
		},
	},
	["Time API"] = {
		{
			Name = "TimestampToDate",
			Type = "Function",
			Info = "Allows you to get the date/time from a specific timestamp. Gives you the ability to specify the format.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Timestamp",
					Type = "Number",
					Info = "If not supplied it will default to the current timestamp",
				},
				{
					Name = "Format",
					Type = "String",
					Info = "- the format of the Time string\n- by default the format is \"#M/#d/#Y #H:#m #a\"\n- Here are the formatting keys: #s  seconds\n								#m  minutes\n								#h  hours\n								#H  hours AM/PM\n								#Y  year\n								#y  year short\n								#a  AM/PM marker\n								#W  month word\n								#M  month numerical\n								#d  day of month\n								#D  day of year\n								#t  total seconds",
				}
			},
			Returns = {
				{
					Name = "Time",
					Type = "String",
					Info = "The formatted time.",
				},
			},
			Example = [[local Date = framework:TimestampToDate(nil, "#M/#d/#Y")
local Time = framework:TimestampToDate(tick(), "#H:#m #a")

print(Date) -->3/8/2015
print(Time) -->10:45 PM]],
		},
		{
			Name = "TimeToString",
			Type = "Function",
			Info = "Turns a time difference into a string. Gives you the option to set the limit for the unit. Gives you the option to set the limit for shortening the unit.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Time",
					Type = "Number",
					Info = "The time difference to convert to a string.",
				},
				{
					Name = "Limit",
					Type = "Number",
					Info = "The unit to limit by, defaulting to 7 (decades, max unit). The units are as follows: 7 = decades\n							6 = years\n							5 = months\n							4 = weeks\n							3 = days\n							2 = hours\n							1 = minutes\n							0 = seconds",
				},
				{
					Name = "ShortLimit",
					Type = "Number",
					Info = "If the unit exeeds this limit, the units will be abbreviated. By default it is 3 (days). The units are the same as the units for Limit",
				}
			},
			Returns = {
				{
					Name = "Time",
					Type = "String",
					Info = "The time string.",
				},
			},
			Example = [[local Time = framework:TimestampToString(301, 7, 0) -- show all units, abbreviate it no matter what
local TimeFull = framework:TimestampToString(301, 7, 7) -- show all units, abbreviate when there is 1 decade
					
print(Time) -->5m 1s
print(TimeFull) -->5 minutes 1 second]],
		},
		{
			Name = "TimestampToString",
			Type = "Function",
			Info = "The exact same as :TimeToString except you supply a timestamp rather than time.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Timestamp",
					Type = "Number",
					Info = "The timestamp to convert to a string.",
				},
				{
					Name = "Limit",
					Type = "Number",
					Info = "The unit to limit by, defaulting to 7 (decades, max unit). The units are as follows: 7 = decades\n							6 = years\n							5 = months\n							4 = weeks\n							3 = days\n							2 = hours\n							1 = minutes\n							0 = seconds",
				},
				{
					Name = "ShortLimit",
					Type = "Number",
					Info = "If the unit exeeds this limit, the units will be abbreviated. By default it is 3 (days). The units are the same as the units for Limit",
				}
			},
			Returns = {
				{
					Name = "Time",
					Type = "String",
					Info = "The time string.",
				},
			},
			Example = [[local Now = tick()
local Time = framework:TimestampToString(Now + 301, 7, 0) -- show all units, abbreviate it no matter what
local TimeFull = framework:TimestampToString(Now + 301, 7, 7) -- show all units, abbreviate when there is 1 decade
					
print(Time) -->5m 1s
print(TimeFull) -->5 minutes 1 second]],
		},
		{
			Name = "GetDate",
			Type = "Function",
			Info = "Gets the date of a timestamp as a table.",
			Restrictions = false,
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Timestamp",
					Type = "Number",
					Info = "If not supplied, it will default to the current timestamp",
				}
			},
			Returns = {
				{
					Name = "Date",
					Type = "Table",
					Info = "A table with all date information. The table goes as follows:\n	total      = seconds since Jan. 1, 1970\n	seconds    = current seconds relative to minute\n	minutes    = current minute relative to hour\n	hours      = current hour (0-23) relative to day\n	hoursPm    = current hour (1-12) relative to day\n	year       = current year (2014)\n	yearShort  = current year (14)\n	isLeapYear = true or false, indicating if current year is a leap year\n	isAm       = true if morning, false if afternoon\n	month      = numerical month of year (3)\n	monthWord  = month of year (March)\n	day        = day of the month\n	dayOfYear  = day of the year",
				},
			},
			Example = false,
		},
	},
	["PlayerList & Chat API"] = {
		{
			Name = "Chat",
			Type = "Function",
			Info = "Creates a chat with a custom username/message.",
			Restrictions = "If called from the client, and FilteringEnabled is true, the chat will only be shown on the client the function is called on.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Sender",
					Type = "String",
					Info = "The chatter.",
				},
				{
					Name = "Message",
					Type = "String",
					Info = "The chat message.",
				},
				{
					Name = "SenderColor",
					Type = "Color3",
					Info = "The color of the username in the chat. This is optional, and is white by default.",
				},
				{
					Name = "MessageColor",
					Type = "Color3",
					Info = "The color of the message in the chat. This is optional, and is white by default.",
				},
			},
			Returns = false,
			Example = [[framework:Chat("[ Server ]", "Xeptix has entered the server!", Color3.new(0,0.5,1), Color3.new(1,1,1))]],
		},
		{
			Name = "AddButtonToPlayerlistDropdown",
			Type = "Function",
			Info = "Adds a button to the dropdown when you click a player on the playerlist.",
			Restrictions = "* Only works with the PlayerlistAPI setting enabled!\n* Can only be called from the client.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to add the button for.",
				},
				{
					Name = "Name",
					Type = "String",
					Info = "The name of the button. This is used to edit the button, or remove it.",
				},
				{
					Name = "ButtonText",
					Type = "String",
					Info = "The actual text of the button",
				},
				{
					Name = "OnClick",
					Type = "Function",
					Info = "The function that is called whenever the button is clicked.",
				},
			},
			Returns = false,
			Example = [[framework:AddButtonToPlayerlistDropdown(game.Players.Xeptix, "view_inv", "View Inventory!", function() Guis.Inventory.Visible = true end)]],
		},
		{
			Name = "RemoveButtonFromPlayerlistDropdown",
			Type = "Function",
			Info = "Removes a button from the dropdown when you click a player on the playerlist.",
			Restrictions = "* Only works with the PlayerlistAPI setting enabled!\n* Can only be called from the client.",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to remove the button for.",
				},
				{
					Name = "Name",
					Type = "String",
					Info = "The name of the button to remove.",
				}
			},
			Returns = false,
			Example = [[framework:RemoveButtonFromPlayerlistDropdown(game.Players.Xeptix, "view_inv")]],
		},
		{
			Name = "SetPlayerlistBackgroundColor",
			Type = "Function",
			Info = "Changes the background color of a player on the playerlist.",
			Restrictions = "* Only works with the PlayerlistAPI setting enabled!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player.",
				},
				{
					Name = "NewColor",
					Type = "Color3",
					Info = "The new background color. To reset to default, make this argument false (NOT nil!)",
				}
			},
			Returns = false,
			Example = [[framework:SetPlayerlistBackgroundColor(game.Players.Xeptix, Color3.new(1,0,0))]],
		},
		{
			Name = "SetPlayerlistNameColor",
			Type = "Function",
			Info = "Changes the name color of a player on the playerlist.",
			Restrictions = "* Only works with the PlayerlistAPI setting enabled!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player.",
				},
				{
					Name = "NewColor",
					Type = "Color3",
					Info = "The new name color. To reset to default, make this argument false (NOT nil!)",
				}
			},
			Returns = false,
			Example = [[framework:SetPlayerlistNameColor(game.Players.Xeptix, Color3.new(0,1,0))]],
		},
		{
			Name = "SetPlayerlistIcon",
			Type = "Function",
			Info = "Changes the icon of a player on the playerlist.",
			Restrictions = "* Only works with the PlayerlistAPI setting enabled!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player.",
				},
				{
					Name = "NewIcon",
					Type = "String",
					Info = "The AssetID of the new icon. To reset to default, make this argument false (NOT nil!)",
				}
			},
			Returns = false,
			Example = [[framework:SetPlayerlistIcon(game.Players.Xeptix, Color3.new(0,1,0))]],
		},
		{
			Name = "AddPlayerlistPrefix",
			Type = "Function",
			Info = "Adds a prefix to the username of a player on the playerlist.",
			Restrictions = "* Only works with the PlayerlistAPI setting enabled!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to add the prefix for.",
				},
				{
					Name = "Name",
					Type = "String",
					Info = "The name of the prefix. This is used to edit the prefix, or remove it.",
				},
				{
					Name = "PrefixText",
					Type = "String",
					Info = "The actual text of the prefix",
				},
				{
					Name = "PrefixColor",
					Type = "Color3",
					Info = "The color of the prefix. To reset to default, make this argument false (NOT nil!)",
				},
			},
			Returns = false,
			Example = [[framework:AddPlayerlistPrefix(game.Players.Xeptix, "clan_tag", "[TDHero] ", Color3.new(0,0,0))]],
		},
		{
			Name = "RemovePlayerlistPrefix",
			Type = "Function",
			Info = "Removes a prefix from the username of a player on the playerlist.",
			Restrictions = "* Only works with the PlayerlistAPI setting enabled!",
			Deprecated = false,
			ChangeLog = {
				
			},
			Arguments = {
				{
					Name = "Player",
					Type = "Instance",
					Info = "The player to remove the prefix for.",
				},
				{
					Name = "Name",
					Type = "String",
					Info = "The name of the prefix to remove.",
				}
			},
			Returns = false,
			Example = [[framework:RemovePlayerlistPrefix(game.Players.Xeptix, "clan_tag")]],
		},
	}
}