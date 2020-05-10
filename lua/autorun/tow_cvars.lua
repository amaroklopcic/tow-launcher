// Made by Raven; Steam Acc: https://steamcommunity.com/id/amaroklopcic

function GetCvar()

	if !ConVarExists("tow_damage_modifier") then
		CreateConVar( "tow_damage_modifier", 1, 256 )
	end
	
	if !ConVarExists("tow_radius_modifier") then
		CreateConVar( "tow_radius_modifier", 1, 256 )
	end
	
	if !ConVarExists("tow_ammo_on_spawn") then
		CreateConVar( "tow_ammo_on_spawn", 4, 256 )
	end
	
	concommand.Add( "tow_missile_stats", function( ply, cmd, args )
		print( "TOW Launcher damage: "..GetConVar("tow_damage_modifier"):GetFloat()*500, "TOW Launcher explosion radius: "..GetConVar("tow_radius_modifier"):GetFloat()*200 )
	end )
	
end
hook.Add( "Initialize", "tow_cvars", GetCvar )