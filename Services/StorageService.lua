-- For storing and fetching serialized data to/from the webserver.


local Requests = 100
local storage = {}
local storageCon = {}
local StorageDB
return {"StorageService", "StorageService", {--
	_StartService = function(self, a, b, c, d, e, f, g, h, i, j, k, l)
		game, Game, workspace, Workspace, table, string, math, typeof, type, Instance, print, require = a, b, c, d, e, f, g, h, i, j, k, l

		if game:Is("Server") then
			pcall(function()
				StorageDB = game:GetService("DataStoreService"):GetDataStore("XeptixFramework_Storage")

			end)

			self:SetEvent("OnUpdate")

			game.ThreadService:Thread(function()
				for _,v in pairs(storage) do
					if v[1] + game.FrameworkHttpService.CachedItemExpieryTime <= os.time() then
						storage[_] = nil
						storageCon[_]:disconnect()
						storageCon[_] = nil
					end--
				end

				Requests = Requests + game.FrameworkHttpService.StorageServicePerMin
				if Requests >= game.FrameworkHttpService.StorageServiceCap then Requests = game.FrameworkHttpService.StorageServiceCap end
			end, {delay = 60, yield = false})
		end

		game:GetService("FrameworkService"):DebugOutput("Service " .. self .. " has started successfully!")
	end,
	Get = function(self, Key, NoCache)
		game.FrameworkService:LockServer(debug.traceback(), "Get")
		--game.FrameworkService:LockConnected(debug.traceback(), "Get")

		local Key = tostring(Key)
		if storage[Key] and not NoCache then
			storage[Key][1] = os.time()
			return storage[Key][2]
		end

		if Requests <= 0 then repeat wait() until Requests >= 1 end Requests = Requests - 1

		local result
		if game:Is("Connected") then
			spawn(function() result = game.FrameworkHttpService:Post("storage_get", {Key = Key}, {json = true}) end)
			local et = tick() + 5
			while et > tick() and not result do wait() end
		end

		local data, data2, data2t
		if StorageDB then
			pcall(function()
				data2 = StorageDB:GetAsync(Key)

				if data2 then
					data2t = data2[1]
					data2 = data2[2]
				end
			end)
		end


		if game:Is("Connected") then
			if result and not result.success and result.error == 404 then
				data = result
			elseif (not result or not result.success) and not data2 then
				game.FrameworkService:DebugOutput("StorageService get request failed, trying again in " .. game.FrameworkHttpService.FailedRequestRepeatDelay .. " second(s)")
				wait(game.FrameworkHttpService.FailedRequestRepeatDelay)

				return self:Get(Key, NoCache)
			elseif result then
				data = result.value
			end
		end


		if (result and result.success) and not data2 then
			-- nothing
		elseif data2 and not (result and result.success) then
			data = data2
		elseif data2 and (result and result.success) then
			if (result.ul or 0) < (data2t or 0) then
				data = data2
			end
		end

		if typeof(data) == "string" and data:find("_____serialized") then
			data = game.FrameworkService:LightUnserialize(data)
		end

		if data then
			if data._____serialized then
				data = game.FrameworkService:LightUnserialize(data)
			elseif data.error then
				data = nil
			end
		end

		storage[Key] = {os.time(), data}

		if not storageCon[Key] and StorageDB then
			storageCon[Key] = StorageDB:OnUpdate(Key, function(Value)
				if storage[Key] and Value then
					game.StorageService.OnUpdate:fire(Key, Value[1], storage[Key][1])
					storage[Key][1] = Value[1]
				elseif not storage[Key] then
					storageCon[Key]:disconnect()
					storageCon[Key] = nil
				end
			end)
		end

		return data
	end,
	Set = function(self, Key, Value, noDB)
		if Requests <= 0 then repeat wait() until Requests >= 1 end Requests = Requests - 1

		game.FrameworkService:LockServer(debug.traceback(), "Set")
		--game.FrameworkService:LockConnected(debug.traceback(), "Set")

		if storage[tostring(Key)] then
			storage[tostring(Key)][1] = os.time()
			storage[tostring(Key)][2] = Value
		else
			storage[tostring(Key)] = {os.time(), Value}
		end

		local oValue = Value
		local Key, Value = tostring(Key), game.FrameworkService:LightSerialize(Value, true)
		local result
		if game:Is("Connected") then
			spawn(function() result = game.FrameworkHttpService:Post("storage_set", {Key = Key, Value = Value}, {json = true}) end)
			local et = tick() + 5
			while et > tick() and not result do wait() end
		end

		if StorageDB and not noDB then
			local s = true
			local s,e = pcall(function()
				StorageDB:SetAsync(Key, {os.time(), Value})
			end)

			if (not result or not result.success) and s then
				result = {success = true}
			end
		end

		if game:Is("Connected") then
			if not result or not result.success then
				game.FrameworkService:DebugOutput("StorageService set request failed, trying again in " .. game.FrameworkHttpService.FailedRequestRepeatDelay .. " second(s)")
				wait(game.FrameworkHttpService.FailedRequestRepeatDelay)

				return self:Set(Key, oValue)
			end
		end

		self.OnUpdate:fire(Key, oValue)

		return oValue
	end,
	Delete = function(self, Key)
		game.FrameworkService:LockServer(debug.traceback(), "Delete")
		game.FrameworkService:LockConnected(debug.traceback(), "Delete")

		local Key = tostring(Key)
		self:Set(Key, nil)
	end,
	Update = function(self, Keys, UpdateFunctions)
		game.FrameworkService:LockServer(debug.traceback(), "Update")
		game.FrameworkService:LockConnected(debug.traceback(), "Update")

		if typeof(Keys) == "table" then
			if typeof(UpdateFunctions) == "table" then
				for _,v in pairs(Keys) do
					Requests = Requests + 1
					local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
					if StorageDB then
						local s = true
						local s,e = pcall(function()
							local DaNew
							StorageDB:UpdateAsync(v, function(Old)
								local RawOld = Old or {}
								local New = f(game.FrameworkService:LightUnserialize(RawOld[2]))

								DaNew = New

								return {os.time(), game.FrameworkService:LightSerialize(New, true)}
							end)

							if DaNew then
								self:Set(v, DaNew, true)
							else
								self:Set(v, f(self:Get(v, true)), true)
							end
						end)

						if not s then print(e) self:Set(v, f(self:Get(v, true))) end
					else
						self:Set(v, f(self:Get(v, true)))
					end
				end
			elseif typeof(UpdateFunctions) == "function" then
				for _,v in pairs(Keys) do
					Requests = Requests + 1
					local f = UpdateFunctions
					if StorageDB then
						local s = true
						local s,e = pcall(function()
							local DaNew
							StorageDB:UpdateAsync(v, function(Old)
								local RawOld = Old or {}
								local New = f(game.FrameworkService:LightUnserialize(RawOld[2]))

								DaNew = New

								return {os.time(), game.FrameworkService:LightSerialize(New, true)}
							end)

							if DaNew then
								self:Set(v, DaNew, true)
							end
						end)

						if not s then print(e) self:Set(v, f(self:Get(v, true))) end
					else
						self:Set(v, f(self:Get(v, true)))
					end
				end
			end
		else
			if typeof(UpdateFunctions) == "table" then
				Requests = Requests + 1
				local f = UpdateFunctions[_] or UpdateFunctions[#UpdateFunctions]
				if StorageDB then
					local s = true
					local s,e = pcall(function()
						local DaNew
						StorageDB:UpdateAsync(Keys, function(Old)
							local RawOld = Old or {}
							local New = f(game.FrameworkService:LightUnserialize(RawOld[2]))

							DaNew = New

							return {os.time(), game.FrameworkService:LightSerialize(New, true)}
						end)

						if DaNew then
							self:Set(Keys, DaNew, true)
						end
					end)

					if not s then print(e) self:Set(Keys, f(self:Get(Keys, true))) end
				else
					self:Set(Keys, f(self:Get(Keys, true)))
				end
			elseif typeof(UpdateFunctions) == "function" then
				Requests = Requests + 1
				local f = UpdateFunctions
				if StorageDB then
					local s = true
					local s,e = pcall(function()
						local DaNew
						StorageDB:UpdateAsync(Keys, function(Old)
							local RawOld = Old or {}
							local New = f(game.FrameworkService:LightUnserialize(RawOld[2]))

							DaNew = New

							return {os.time(), game.FrameworkService:LightSerialize(New, true)}
						end)

						if DaNew then
							self:Set(Keys, DaNew, true)
						end
					end)

					if not s then print(e) self:Set(Keys, f(self:Get(Keys, true))) end
				else
					self:Set(Keys, f(self:Get(Keys, true)))
				end
			end
		end
	end
}}
