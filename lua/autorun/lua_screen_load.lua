
if SERVER then
	AddCSLuaFile("lua_screen/cl_init.lua")
	AddCSLuaFile("lua_screen/sh_init.lua")
end

include("lua_screen/sh_init.lua")

if SERVER then
	include("lua_screen/sv_init.lua")
end

if CLIENT then
	include("lua_screen/cl_init.lua")
end

