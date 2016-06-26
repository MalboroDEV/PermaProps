/*
   ____          _          _   ____          __  __       _ _
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/
                                      |___/
						Thanks to ARitz Cracker for this part
*/

local function PermaPropsPhys( ply, ent, phys )

	if ent.PermaProps then

		if PermaProps.IsAdmin(ply) and PermaProps.Permissions["PhysA"] then

			return true

		elseif PermaProps.IsSuperAdmin(ply) and PermaProps.Permissions["PhysSA"] then

			return true

		else

			return false

		end

	end

end
hook.Add("PhysgunPickup", "PermaPropsPhys", PermaPropsPhys)
hook.Add( "CanPlayerUnfreeze", "PermaPropsUnfreeze", PermaPropsPhys) -- Prevents people from pressing RELOAD on the physgun

hook.Add( "CanTool", "PermaPropsTool", function( ply, tr, tool )

	if IsValid(tr.Entity) and tr.Entity.PermaProps then

		if tool == "permaprops" then

			return true

		end

		if ULib and ULib.ucl and PermaProps.Permissions["ULXMod"] == true then

			return ULib.ucl.query( ply, "permaprops_tool" )

		else

			if PermaProps.IsAdmin(ply) and PermaProps.Permissions["ToolA"] then -- Make another convar option if you want.

				return true

			elseif PermaProps.IsSuperAdmin(ply) and PermaProps.Permissions["ToolSA"] then

				return true

			else

				return false

			end

		end

	end

end)

hook.Add( "CanProperty", "PermaPropsProperty", function( ply, property, ent ) -- Context Menu (Right clicking on the entity)

	if IsValid(ent) and ent.PermaProps and tool ~= "permaprops" then

		if ULib and ULib.ucl and PermaProps.Permissions["ULXMod"] == true then

			return ULib.ucl.query( ply, "permaprops_property" )

		else

			if PermaProps.IsAdmin(ply) and PermaProps.Permissions["PropA"] then -- Make another convar option if you want.

				return true

			elseif PermaProps.IsSuperAdmin(ply) and PermaProps.Permissions["PropSA"] then

				return true

			else

				return false

			end

		end

	end

end)

timer.Simple(5, function() hook.Remove("CanTool", "textScreensPreventTools") end) -- Fuck OFF
timer.Simple(5, function() hook.Remove("CanTool", "textscreenpreventtools") end)
