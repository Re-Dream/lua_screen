
local tag = "lua_screen"

luascreen.Screens = {}

function luascreen.RegisterScreen(id, scr)
	local found = false
	for _, ent in next, ents.FindByClass(tag) do
		if ent.Identifier == id then
			found = true
			table.Merge(ent, scr)
		end
	end
	if found then
		luascreen.Print("refreshed \"" .. id .. "\" screens")
	end
	luascreen.Screens[id] = scr
end

for _, file in next, (file.Find("lua_screen/screens/*.lua", "LUA")) do
	AddCSLuaFile("lua_screen/screens/" .. file)

	_G.ENT = {}
	include("lua_screen/screens/" .. file)
	if ENT.Identifier then
		luascreen.RegisterScreen(ENT.Identifier, table.Copy(ENT))
	else
		ErrorNoHalt("no identifier for file " .. file)
	end
	ENT = nil
end

function luascreen.GetScreens(id)
	local tbl = {}
	for _, ent in next, ents.FindByClass("lua_screen") do
		if not id or ent.Identifier == id then
			tbl[#tbl + 1] = ent
		end
	end
	return tbl
end

if SERVER then
	function luascreen.SpawnScreen(id, pos, ang, scale)
		local screen = ents.Create(tag)
		if id    then screen:SetScreen(id)  end
		if pos   then screen:SetPos(pos)    end
		if ang   then screen:SetAngles(ang) end
		if scale then screen:SetScale(scale)end
		screen:Spawn()
		return screen
	end

	function luascreen.PlaceScreens()
		for _, screen in next, luascreen.GetScreens() do
			if screen.MapPlaced then
				screen:Remove()
			end
		end

		local exists = ""
		for _, filename in next, (file.Find("lua_screen/placement/*.lua", "LUA")) do
			if game.GetMap():match(filename:StripExtension()) and #exists <= #filename then
				exists = filename
			end
		end
		if exists:Trim() ~= "" then
			luascreen.Placement = include("lua_screen/placement/" .. exists)

			for _, data in next, luascreen.Placement do
				local screen = luascreen.SpawnScreen(data.id, data.pos, data.ang, data.scale)
				screen.MapPlaced = true
				screen:Grip(false)
			end
		end
	end
	hook.Add("InitPostEntity", tag, luascreen.PlaceScreens)
	hook.Add("PostCleanupMap", tag, luascreen.PlaceScreens)
end

