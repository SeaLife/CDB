-- Database Class
require("mysqloo")


local function printMsg(str)
	print("[CentralDatabase mysqloo] " .. str)
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

function DatabasePool.new(poolName, host, port, user, pass, db, typ)
	if typ == nil then typ = "tmysql4" end
	if CentralDatabase.Pools[ poolName ] ~= nil then return nil end

	local pool = { }
	setmetatable(pool, DatabasePool)

	local connection = mysqloo.connect( host, user, pass, db, port )

	pool.host 		= host
	pool.port 		= port
	pool.user 		= user
	pool.pass 		= pass
	pool.db 		= db
	pool.connection = connection
	pool.poolName 	= poolName
	pool.backlog 	= { }

	function connection:onConnected()
		pool:ProcessBacklog()
		printMsg( "Connection Success for Pool " .. poolName)
	end

	function connection:onConnectionFailed( err )
		printMsg( "Connection to database failed!" )
		printMsg( "Error:", err )
	end

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

	self.backlog = { }
end

function DatabasePool:GetConnection()
	return self.connection
end

function DatabasePool:Connect()
	self.connection:connect()
end

function DatabasePool:GetName()
	return self.poolName
end

function DatabasePool:Query(sql, callback, errCall)
	errCall = errCall or nil
	callback = callback or nil

	local pool = self

	local query = pool:GetConnection():query(sql)

	if query == nil then
		self:AddBacklog(sql, callback, errCall)
		self:Connect()
		return
	end

	-- printMsg("Processing SQL (Pool :: " .. pool:GetName() .. ") [" .. sql .. "]")

	function query:onSuccess(data)
		if callback ~= nil then
			callback(data)
		end
	end

	function query:onError(err)
		if pool:GetConnection():status() ~= mysqloo.DATABASE_CONNECTED then
			pool:AddBacklog(sql, callback, errCall)
			pool:Connect()
			return
		end

		if errCall ~= nil then errCall(err, sql) else
			printMsg( "(GenericError :: " .. err .. ") sql: [" .. sql .. "]")
		end
	end

	query:start()
end

function CentralDatabase.ConnectDatabase()
	printMsg("CentralDatabase Init...")
	for k, v in pairs( CentralDatabase.Pools ) do
		printMsg("Connecting to: " .. v:GetName() )
		v:Connect()
	end

	hook.Call("CentralDatabase::ConnectedPools")
end