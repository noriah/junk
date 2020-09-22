--[[
    Title: showadmins
    Author: noriah <vix@noriah.dev>

    To Emulate the sm_admin command on Source Games
]]


--List Online Admins like in Source Games
--Username  Fourm Name  Group

function UMaul.listAdmins(calling_ply)
    local str = "Name\t\t\t\tForum Name\t\t\tRank\n"
    local plys = UMaul.users.getAllPlayers()
    for plyID, ply in pairs(plys) do
        if ply then
            local nick = ULib.getPlyByID(tostring(plyID)):Nick()
            str = str .. nick .. "\t\t\t\t" .. ply['forum_name'] .. "\t\t\t\t" .. ply['rank'] .. "\n"
        end
    end
    calling_ply:PrintMessage(HUD_PRINTCONSOLE, str)
end
local list_admins = ulx.command("Utility", "ulx admin", UMaul.listAdmins, nil, false)
list_admins:defaultAccess(ULib.ACCESS_OPERATOR)
list_admins:help("List all players and admin access.")
