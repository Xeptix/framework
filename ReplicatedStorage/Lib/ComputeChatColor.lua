--[[
	File: ComputeChatColor.lua
	Author: Xeptix
	Info: Computes the chat color from a username. This is modified code I found on the ROBLOX Forum.
--]]


local ChatColors = {
	BrickColor.new("Persimmon"),
	BrickColor.new("Electric blue"),
	BrickColor.new("Parsley green"),
	BrickColor.new("Eggplant"),
	BrickColor.new("Deep orange"),
	BrickColor.new("Bright yellow"),
	BrickColor.new("Pink"),
	BrickColor.new("Br. yellowish orange"),
}
--[[local ChatColors = {
	BrickColor.new("Bright red"),
	BrickColor.new("Bright blue"),
	BrickColor.new("Earth green"),
	BrickColor.new("Bright violet"),
	BrickColor.new("Bright orange"),
	BrickColor.new("Bright yellow"),
	BrickColor.new("Light reddish violet"),
	BrickColor.new("Brick yellow"),
}]]

local function GetNameValue(pName)
	local value = 0
	for index = 1, #pName do
		local cValue = string.byte(string.sub(pName, index, index))
		local reverseIndex = #pName - index + 1
		if #pName%2 == 1 then
			reverseIndex = reverseIndex - 1 
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue 
		end
		value = value + cValue
	end
	return value%8
end

return function(pName)
	return ChatColors[GetNameValue(pName) + 1].Color
end
