--[[
	Title: Defines
	Author: noriah <vix@noriah.dev>

	Holds some defines used on server.
]]


--[[
	Hook: UMaulAuthed

	Called *on both server and client* when a player is authenticated by UMaul

	Parameters passed to callback:

		ply - The player that got authenticated.
		rank - The players rank in a text for (i.e. superadmin)

]]
UMaul.HOOK_AUTHED = "UMaulAuthed"

--[[
	Hook: UMaulDBReady

	Called when UMaul has connected to the mysql database

]]
UMaul.HOOK_DB_READY = "UMaulDBReady"

--[[
	Hook: UMaulUserChange

	Called when the UMaul Users list has been updated Does not necessarily mean that
	a user was authenticated by UMaul. It simply means we added or removed a player from the UMaul List

]]
UMaul.HOOK_USERS_CHANGED = "UMaulUserChange"


UMaul.CONF_FILE = "data/umaul/config.txt"
UMaul.HOOKGMAUTH = "UMaulGmPlayerAuthed"
UMaul.HOOKGMDISCONNECT = "UMaulGmPlayerDisconnected"
UMaul.HOOKUMLSAC = "UMaulSendAuthedClient"

hook.Add("Initialize", "UMaulInit", function()
	if ULib.fileExists(UMaul.CONF_FILE) and ULib.fileRead(UMaul.CONF_FILE) == ULib.fileRead("addons/ego-umaul/" .. UMaul.CONF_FILE) then
		ULib.fileWrite(UMaul.CONF_FILE, ULib.removeCommentHeader(ULib.fileRead("addons/ego-umaul/" .. UMaul.CONF_FILE), "/"))
		Msg("[UMAUL] Default Config file writtent to: garrysmod/" .. UMaul.CONF_FILE .. "\n")
		Msg("[UMAUL] Please go Edit that file.\n")
		UMaul.disable("Unconfigured")
		return

	else
		UMaul.config = ULib.parseKeyValues(ULib.fileRead(UMaul.CONF_FILE) or "") or {}
		if not UMaul.config['mysql'] then
			Msg("[UMAUL] Corrupt config file (" .. UMaul.CONF_FILE .. ")\n")
			Msg("[UMAUL] Please delete garrysmod/" .. UMaul.CONF_FILE .. "\n")
			Msg("[UMAUL] And restart.")
			UMaul.disable("Unconfigured")
			return
		end
	end
	UMaul.sql.connect()
end)
