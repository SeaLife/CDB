
-- Pool Example
DatabasePool.new(
	"demoPool", 	-- Name of Pool (for Internal Usage)
	"databasehost", -- Host of Database
	3306, 			-- Port of Database
	"demouser", 	-- User for Authentication
	"password", 	-- Password for Authentication
	"demodb"		-- Database Name
)

CentralDatabase.Mode = "tmysql4" -- Connection Mode (can be tmysql4 or mysqloo)