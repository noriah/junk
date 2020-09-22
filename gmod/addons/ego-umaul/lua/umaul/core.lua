--[[
	Title: UMaul
	Author: noriah <vix@noriah.dev>

	UMaul Library Functions
]]


--[[
	Function: UMaul.playerAuthed

	Called when a player is authenticated by GMod
	This will be called after ULib runs its stuff, so we wont run into any errors (hopefully)
	Unless the player disconnects between then and now

	Parameters:

		ply - [Player] The player that we are authenticating
		uId - [String] The unique ID of the player. We dont grab this from the ply object because it is expensive

]]
function UMaul.playerAuth(ply, uId)
	if ply and ply:IsValid() then
		-- If the player is valid, ask sql to get the data
		-- Once sql has the data, it will queue a functon that will
		-- take care of the rest of the process

		-- We queue this so it wont hold up the main thread
		ULib.queueFunctionCall(UMaul.sql.queryUserData, ply, uId)
	end
	-- If the player does not exist or is not valid, do noting
end

--[[
	Function: UMaul.disable

	Should only be called when a Fatal error has occured in UMAUL
	Like if the config file is not filled in, or it is corrupt.
	Or if MySQL comes back with an error.

	Parameters:

		reason - [String] The reason for disabling

]]
function UMaul.disable(reason)
	Msg("[UMAUL] Disabling UMAUL -> [" .. reason .. "]\n")
	hook.Remove(UMaul.HOOKGMAUTH)
	hook.Remove(UMaul.HOOKGMDISCONNECT)
	hook.Remove(UMaul.HOOKUMLSAC)
end

--[[
	Section: Player Management

	UMaul Functions for managing players.
]]


--Create the UMaul.pm table
UMaul.pm = {}

-- Create a local pm for easy definitons
local pm = UMaul.pm

--[[
	Function: pm.setUserGroup

	Starts the registration process. Gets the required info that sql didn't have.

	Parameters:

		ply - [Player] The player we are adding to a group
		uId - [String] The unique ID of the player. We dont grab this from the ply object because it is expensive
		group_name - [String] The group we are adding the player to.

]]
function pm.setUserGroup(ply, uId, group_name)

	-- Incase we already have a player in the users file, registered by ip
	local ip = ULib.splitPort( ply:IPAddress() )
	local id = nil

	-- Search for the player that has already been registered by ULib
	-- We are going to re-register them
	for _, index in ipairs({uId, ip, ply:SteamID()}) do
		if ULib.ucl.authed[ index ] then
			id = index
			break
		end
	end
	if not id then id = ply:SteamID() end
	local userInfo = ULib.ucl.authed[id] or {allow = {}, deny = {}}

	-- Add the user to the group
	pm.registerUser(id, group_name, userInfo.allow, userInfo.deny)
end

--[[
	Function: pm.registerUser

	Sets a user to their correct group.

	Parameters:

		id - [Player] The id of the player related to the Ulib.pm.authed table
		group - [String] The name of the group to add the player to
		allows - [Table] *(Optional)* A list of allowed commands. Follow ulx and ulib access tags and commands
		denies - [Table] *(Optional)* A list of denied commands. Follow ulx and ulib access tags and commands

]]
function pm.registerUser(id, group, allows, denies)

	id = id:upper() -- In case of steamid, needs to be upper case

	-- Handle nil values
	allows = allows or {}
	denies = denies or {}

	-- If the user has no speical permissions, copy the default permissions
	if allows == ULib.DEFAULT_GRANT_ACCESS.allow then allows = table.Copy(allows) end -- Otherwise we'd be changing all guest access
	if denies == ULib.DEFAULT_GRANT_ACCESS.deny then denies = table.Copy(denies) end -- Otherwise we'd be changing all guest access
	-- Make sure we have a group to add the user to
	if group and not ULib.ucl.groups[group] then return error("Group does not exist for adding user to (" .. group .. ")", 2) end

	-- Lower case'ify
	for k, v in ipairs(allows) do allows[k] = v:lower() end
	for k, v in ipairs(denies) do denies[k] = v:lower() end

	-- If we already have a name set, use it
	local name
	if ULib.ucl.users[id] and ULib.ucl.users[id].name then name = ULib.ucl.users[id].name end

	-- Get the player
	local ply = ULib.getPlyByID(id)

	-- If we don't already have the user in the save file, don't add them.
	if ULib.ucl.users[id] and not ULib.ucl.users[id].group == group then
		-- Set the user data in the users table, so it will be saved.
		-- This is only if the user has extra permissions in addition to their group
		-- Or if the user was already in the users file
		ULib.ucl.users[id] = {allow=allows, deny=denies, group=group, name=name}

		-- Probe ULib ucl to update the authed data correctly
		ULib.ucl.probe(ply)
	else
		-- Set the users authenticated data
		ULib.ucl.authed[id] = {allow=allows, deny=denies, group=group, name=name}

		-- Set the users group for ulx and other purposes
		ply:SetUserGroup(group, true)

		-- Set the players name so addons get it right
		ULib.ucl.authed[id].name = ply:Nick()

		-- Tell the rest of the world we have updated a player
		-- This tells ulx to update as well as any plugins using the UCLChanged and UCLAuthed hooks
		hook.Call(ULib.HOOK_UCLCHANGED)
		hook.Call(ULib.HOOK_UCLAUTH, _, ply)
	end
	hook.Call(UMaul.HOOK_AUTHED, _, ply)
end

--[[
	Section: User List

	This section defines the user list. A seperate list from ULib/ULX that holds
	a players SteamID, Forum Name(If they are regiserted), and Rank(if they have one)

]]

UMaul.users = {}

local users = UMaul.users

users.list = {}

--[[
	Function: users.insertPlayer

	Add a player to the UMaul Users list.

	Parameters:

		ply - [Player] The player we are adding to the list
		forumname - [String]*(Optional)* The forum name of the player. Can be nil
		ply_rank - [String] *(Optional)* The rank of the player. Can be nil

]]
function users.insertPlayer(ply, forumname, ply_rank)
	local fname = forumname or ""
	local prank = ply_rank or "None"
	users.list[ply:UserID()] = {steamid=ply:SteamID(), forum_name=fname, rank=prank}
	hook.Call(UMaul.HOOK_USERS_CHANGED)
end

--[[
	Function: users.removePlayer

	Removes a player from the UMaul Users list.

	Parameters:

		ply - [Player] The player we are removing from the list

]]
function users.removePlayer(ply)
	users.list[ply:UserID()] = nil
	hook.Call(UMaul.HOOK_USERS_CHANGED)
end

--[[
	Function: users.getAllPlayers

	Returns the UMaul Users list
	DO NOT JUST REFERENCE UMaul.users.list UNLESS YOU PLAN TO MODIFY IT!

	Parameters:

		ply - [Player] The player we are removing from the list

	Returns:

		The UMaul users list

]]
function users.getAllPlayers()
	--table.sort(users.list)
	return table.Copy(users.list)
end

--[[
	Function: users.getForumName

	Returns the forum name of the player
	DO NOT JUST REFERENCE UMaul.users.list UNLESS YOU PLAN TO MODIFY IT!

	Parameters:

		ply - [Player] The player we are removing from the list

	Returns:

		The UMaul users list

]]
function users.getForumName(ply)
	local id = ply:UserID()
	if users.list[id] and users.list[id].forum_name then return users.list[id] else return "" end
end


--[[
	Section: Hook Handlers

	These are ids for the ULib umsg functions, so the client knows what they're getting.
]]

-- Callend when a player is Authorized by GMod
-- Runs after ULib, so there should be no errors
local function gmPlayerAuthed(ply, steamId, uId)
	UMaul.playerAuth(ply, uId)
end
hook.Add("PlayerAuthed", UMaul.HOOKGMAUTH, gmPlayerAuthed, 20) -- Run last

-- Called when a player Disconnects from the Server
local function gmPlayerDisconnected(ply)
	users.removePlayer(ply)
end
hook.Add("PlayerDisconnected", UMaul.HOOKGMDISCONNECT, gmPlayerDisconnected, 20) -- Run last

-- Called when a player is authorized by UMaul.
local function sendUMaulAuthed(ply, rank)
	ULib.clientRPC(ply, "hook.Call", UMaul.HOOK_AUTHED, _, rank ) -- Call hook on client. Tell them their rank
end
hook.Add(UMaul.HOOK_AUTHED, UMaul.HOOKUMLSAC, sendUMaulAuthed, -20)
