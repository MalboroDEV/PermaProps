util.AddNetworkString( "PP.SammysTextscreen" )
net.Receive("PP.SammysTextscreen", function(len, ply)
  ent = net.ReadEntity()
  ply = net.ReadEntity()

  if not PermaProps then ply:ChatPrint( "ERROR: Lib not found" ) return end

	if not PermaProps.HasPermission( ply, "Save") then return end

	if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end
	if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
	if ent.PermaProps then ply:ChatPrint( "That entity is already permanent !" ) return end

	local content = PermaProps.PPGetEntTable(ent)
	if not content then return end

	local max = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;"))
	if not max then max = 1 else max = max + 1 end

	local new_ent = PermaProps.PPEntityFromTable(content, max)
	if not new_ent or not new_ent:IsValid() then ply:ChatPrint("new_ent") return end

	PermaProps.SparksEffect( ent )

	PermaProps.SQL.Query( "INSERT INTO permaprops (id, map, content) VALUES(NULL, " .. sql.SQLStr(game.GetMap()) .. ", " .. sql.SQLStr(util.TableToJSON(content)) .. ");")
	ply:ChatPrint("You saved " .. ent:GetClass() .. " with model " .. ent:GetModel() .. " to the database.")
  --print(CurTime())
	ent:Remove()

	return true

end)
