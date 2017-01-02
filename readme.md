# Central Database Mod

This Addon was created by SeaLife

## Hooks

| Hook Name | Action |
|-----------|--------|
| CentralDatabase::ConnectedPools | Will be called if all Pools are connected |


## How to create a Database Pool

```
DatabasePool.new(
	"demoPool", 	-- Name of Pool (for Internal Usage)
	"db.host.com",  -- Host of Database
	3306, 			-- Port of Database
	"demouser", 	-- User for Authentication
	"password", 	-- Password for Authentication
	"demodb"		-- Database Name
)
```

## How to get a Database Pool

| Function | Arguments | Returns |
|-----------|--------| -------- |
| CentralDatabase.GetPool | string poolName | returns the pool object for poolName |

```
CentralDatabase.GetPool( String poolName )
```


#### Example

```
local db = nil

local function onDatabaseConnected()
	db = CentralDatabase.GetPool("demoPool")
end

hook.Add("CentralDatabase::ConnectedPools", "TestOnDatabaseConnected", onDatabaseConnected)
```

## How to use a Database Pool

```
db:Query( String sql, Function callback, Function errorCallback )
```
