-- Central Database Service
CentralDatabase = CentralDatabase or { }

CentralDatabase.Mode = "tmysql4"

include('database/modules/sv_' .. CentralDatabase.Mode .. '.lua')

include('database/sv_config.lua')

hook.Add("Initialize", "InitializeCentralDatabase", CentralDatabase.ConnectDatabase)
