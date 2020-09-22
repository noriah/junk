--[[
    Title: MySQL Interface
    Author: noriah <vix@noriah.dev>

    Interfacing with the MySQL Server for MAUL admin
]]

require("mysqloo")


UMaul.sql = {}
local sql = UMaul.sql

local db = nil

function sql.connect()
	local sqlC = UMaul.config.mysql or {db_host="127.0.0.1", db_user="", db_pass="", db_name="", db_port=3306}

	db = mysqloo.connect(sqlC.db_host, sqlC.db_user, sqlC.db_pass, sqlC.db_name, tonumber(sqlC.db_port))

	function db:onConnected()

		Msg("[UMAUL] MySQL Connection Ready!\n")

		hook.Call(UMaul.HOOK_DB_READY)
	end

	-- What to do when we can't connect to the mysql server
	function db:onConnectionFailed( err )
		print( "[UMAUL] MySQL Error:", err )
		UMaul.disable("MySQL Not Connected")
	end

	db:connect()
end

-- Function called when we want data on someone
-- Should only be called when a player connects
function sql.queryUserData(ply, uId)

	-- Escape the steamId, incase someone got sneaky with gmod
	local sSteamId = db:escape(ply:SteamID())

	-- I have no Idea what your Table structure(s) are. So I made up my own for testing.
	-- On my test db, Permission is the rank, either 1, 2, 3, or 4.
	-- To change how groups are assigned, edit the 'sql.handleData' function

	local q = db:query("SELECT m.permission, m.pin, f.forumname FROM maul m INNER JOIN forum f ON m.forumid = f.forumid WHERE m.steamid = '" ..sSteamId.. "';")

	-- Function called when the query returns.
	function q:onSuccess(data)
		-- Get the data and convert it to a common table
		local d = {forum_name = nil, perms = nil, pin = nil}
		-- If they are an eGO Memeber, they will (I expect) have data here
		if data and data[1] then
			d.forum_name = data[1]['forumname']
			d.perms = data[1]['permission']
			d.pin = data[1]['pin']
		end
		-- If they are not a member, then null data is returned

		-- Queued so we don't hold up any threads
		ULib.queueFunctionCall(sql.handleSqlData, ply, uId, d)
	end

	-- Called when the query returns with an error
	function q:onError( err, sql )
        print( "[UMAUL] Query errored!" )
        print( "[UMAUL] Query:", sql )
        print( "[UMAUL] Error:", err )
    end

	q:start()
end

--[[
	Function: sql.handleSqlData

	Function called when sql returns data

	Parameters:

		ply - [Player] The player we are processing
		uId - [String] The unique ID of the player. We dont grab this from the ply object because it is expensive
		sData - [Table] The sql data returned from the query

]]
local groups = {"user", "operator", "admin", "superadmin"}
function sql.handleSqlData(ply, uId, sData)
	if ply and ply:IsValid() then

		local fname = sData['forum_name'] or ""
		local sPin = sData['pin'] or nil

		local pin = ply:GetInfo(UMaul.config.PIN_KEY_NAME) or nil
		if pin == "" then pin = nil end

		local group = nil

		-- Not quite sure how the group is figured out
		-- Since I don't know the Table stucture or the values for permissions,
		-- Im just going to put dummy code here
		if fname ~= "" then
			if pin and sPin and pin == sPin then
				group = groups[sData['perms']] or "user"
			else
				-- This is to force the UMaulAuthed hook
				-- This way, any addon or plugin that is added later can tell
				-- which players are ego members, even if they are not admins
				-- or if the admin has an incorrect maul pin
				group = "user"
			end
			UMaul.pm.setUserGroup(ply, uId, group)
		end
		UMaul.users.insertPlayer(ply, fname, group)
	end
end
