-- Allows the framework to be compatible with games that use the framework, that were made before v2 released (at least 25 known games)
-- If you delete this script, you might break something.

-- Basically, in newer versions, _G.framework no longer exists.
-- Rather, you are supposed to require the "XeptixFramework" module in ReplicatedStorage.
-- This script makes _G.framework work, while maintaining v2 functionality.

-- Even if you do not use _G.framework in your game, it is still recommended you keep this script, as it speeds up framework loading.



-- TL;DR	-	Keep this to maintain functionality & loading speed.















-- I wouldn't touch anything :P
local f = game:FindFirstChild("XeptixFrameworkModule", true)
if not f then
	repeat
		wait()
		f = game:FindFirstChild("XeptixFrameworkModule", true)
	until f
end

_G.framework = require(f)
_G.frameworkready = true
