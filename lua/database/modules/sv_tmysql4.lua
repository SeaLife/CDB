-- Database Class
require("tmysql4")


local function printMsg(str)
	print("[CentralDatabase tmysql4] " .. str)
end

-- Pool Handling
CentralDatabase.Pools = CentralDatabase.Pools or { }

function CentralDatabase.GetPool(poolName)
	if(CentralDatabase.Pools[poolName] ~= nil) then
		return CentralDatabase.Pools[poolName]
	else
		return nil
	end
end


-- DatabasePool Object
DatabasePool = { }
DatabasePool.__index = DatabasePool

function DatabasePool.new(poolName, host, port, user, pass, db)
	if CentralDatabase.Pools[ poolName ] ~= nil then return nil end

	local pool = { }
	setmetatable(pool, DatabasePool)

	local connection, err = tmysql.initialize( host, user, pass, db, port, nil, CLIENT_MULTI_STATEMENTS )
	--local connection = tmysql.Create( host, user, pass, db, port, nil, CLIENT_MULTI_STATEMENTS )

	if err ~= nil then
		print("[Central Database Error :: " .. poolName .. "]: " .. err)
		return
	end

	pool.host 		= host
	pool.port 		= port
	pool.user 		= user
	pool.pass 		= pass
	pool.db 		= db
	pool.connection = connection
	pool.poolName 	= poolName
	pool.backlog 	= { }

	CentralDatabase.Pools[poolName] = pool
	printMsg("Creating DatabasePool " .. poolName)

	return pool
end

function DatabasePool:AddBacklog(sql, callback, errCall)
	table.insert(self.backlog, {SQL=sql, CallBack=callback, ErrorCall=errCall})
end

function DatabasePool:ProcessBacklog()
	for k, v in pairs( self.backlog ) do
		self:Query(v.SQL, v.CallBack, v.ErrorCall)
	end

	table.Empty(self.backlog)
	self.backlog = { }
end

function DatabasePool:GetConnection()
	return self.connection
end

function DatabasePool:Connect()
	local success, err = self.connection:Connect()

	if not success then
		self:onConnectionFailed(err)
		return
	end

	self:onConnected()
	self:ProcessBacklog() 
end

-- Blank CONNECTION FUNCTION
function DatabasePool:onConnectionFailed(err) end
function DatabasePool:onConnected() printMsg("Connected to: " .. self:GetName() ) end

function DatabasePool:GetName()
	return self.poolName
end

function DatabasePool:Query(sql, callback, errCall)
	local pool = self

	if not pool:GetConnection():IsConnected() then
		printMsg("[" .. pool:GetName() .. "]: Connect to Database ..." )
		pool:Connect()
	end

	callback = callback or nil
	errCall = errCall or nil

	pool:GetConnection():Query(sql, function(res)
		if res[1].data then
			printMsg("[" .. pool:GetName() .. "]: Invoke Success '" .. sql .. "'" )
			if callback ~= nil then callback(res[1].data) end
		else
			printMsg("[" .. pool:GetName() .. "]: Invoke Failed '" .. sql .. "'" )
			if errCall ~= nil then errCall(res.error) end

			if res.error then
				if string.find( res.error, "Syntax", 1 ) == nil then
					printMsg("[" .. pool:GetName() .. "]: Added [" .. sql .. "] to Backlog SQL Processing...")
					pool:AddBacklog(sql, callback, errCall)
				end
			end
		end
	end)
end

function CentralDatabase.ConnectDatabase()
	printMsg("CentralDatabase Init...")
	for k, v in pairs( CentralDatabase.Pools ) do
		printMsg("Connecting to: " .. v:GetName() )
		v:Connect()
	end

	hook.Call("CentralDatabase::ConnectedPools")
end