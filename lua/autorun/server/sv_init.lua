-- Central Database Service
CentralDatabase = CentralDatabase or { }

CentralDatabase.Mode = "tmysql4"

include('database/sv_config.lua')

include('database/modules/sv_' .. CentralDatabase.Mode .. '.lua')

hook.Add("Initialize", "InitializeCentralDatabase", CentralDatabase.ConnectDatabase)