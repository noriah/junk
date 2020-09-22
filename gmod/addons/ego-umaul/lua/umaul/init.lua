--[[
    Title: UMaul Init
    Author: noriah <vix@noriah.dev>

    Initiate UMAUL
]]

if not UMaul then
    UMaul = {}

    ULib.fileCreateDir("data/umaul")

    local sv_modules = file.Find("umaul/modules/*.lua", "LUA")

    Msg("///////////////////////////////\n")
    Msg("// eGO MAUL ULib Connector   //\n")
    Msg("// Created by noriah         //\n")
    Msg("///////////////////////////////\n")
    Msg("// Loading UMAUL...          //\n")
    Msg("//   defines.lua             //\n")
    include("defines.lua")
    Msg("//   core .lua               //\n")
    include("core.lua")
    Msg("//   mysql.lua               //\n")
    include("mysql.lua")

    Msg("///////////////////////////////\n")

    for _, file in ipairs( sv_modules ) do
        Msg( "//   MODULE: " .. file .. string.rep( " ", 16 - file:len() ) .. "//\n" )
        include( "modules/" .. file )
    end

    Msg("// Load Complete!            //\n")
    Msg("///////////////////////////////\n")
end
