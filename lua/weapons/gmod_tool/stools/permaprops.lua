/*
	PermaProps
	Created by Entoros, June 2010
	Facepunch: http://www.facepunch.com/member.php?u=180808
	Modified By Malboro 28 / 12 / 2012
	
	Ideas:
		Make permaprops cleanup-able
		
	Errors:
		Errors on die

	Remake:
		By Malboro the 28/12/2012
*/

sql.Query("CREATE TABLE IF NOT EXISTS permaprops('id' INTEGER NOT NULL, 'map' TEXT NOT NULL, 'content' TEXT NOT NULL, PRIMARY KEY('id'));")

CreateConVar( "pp_phys_admin", 0, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Admin can touch permaprops" )
CreateConVar( "pp_phys_sadmin", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Only Super Admin can touch permaprops" )

TOOL.Category		=	"SaveProps"
TOOL.Name			=	"PermaProps"
TOOL.Command		=	nil
TOOL.ConfigName		=	""

if(CLIENT)then
	language.Add("Tool.permaprops.name", "PermaProps")
	language.Add("Tool.permaprops.desc", "Save a props permanently")
	language.Add("Tool.permaprops.0", "LeftClick: Add RightClick: Remove Reload: Update")
end

local function RebuildOldTable( data )

	local e = ents.Create( data.class )
	if !e or !e:IsValid() then return end
	e:SetRenderMode( RENDERMODE_TRANSALPHA )
	e:SetPos( data.pos )
	e:SetAngles( data.ang )
	e:SetColor( data.color )
	e:SetModel( data.model )
	e:SetMaterial( data.material )
	e:SetSkin( data.skin )
	e:SetSolid( data.solid )
	e:SetCollisionGroup( data.collision or 0)
	e:Spawn()

	local content = duplicator.CopyEntTable( e )
	content.Constraints = {}
	content.ConstraintSystem = {}

	e:Remove()

	local new_ent = duplicator.CreateEntityFromTable(nil, content)
	new_ent.ID = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;")) or 1
	new_ent.PermaProps = true
	new_ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	new_ent:SetMoveType(0)

	sql.Query("INSERT INTO permaprops (id, map, content) VALUES(NULL, ".. sql.SQLStr(game.GetMap()) ..", ".. sql.SQLStr(util.TableToJSON(content)) ..");")


end

function ReloadPermaProps()
	
	for k, v in pairs( ents.GetAll() ) do

		if v.PermaProps == true then

			v:Remove()

		end

	end

	local content = sql.Query( "SELECT * FROM permaprops" )

	if content == nil then return end
	
	for k, v in pairs( content ) do

		if game.GetMap() == v.map then

			local data = util.JSONToTable(v.content)

			if data.pos != nil then
				
				RebuildOldTable(data)
				sql.Query("DELETE FROM permaprops WHERE id = ".. v.id ..";")
				continue

			end

			local e = duplicator.CreateEntityFromTable(nil, data)
			if !e or !e:IsValid() then continue end
			e:SetRenderMode( RENDERMODE_TRANSALPHA )
			e:SetMoveType(0)
			e.PermaProps = true
			e.ID = v.id

			local phys = e:GetPhysicsObject()
			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end

		end

	end

end
hook.Add("InitPostEntity", "InitializePermaProps", ReloadPermaProps)

function TOOL:LeftClick(trace)

	if (CLIENT) then return end

	if not trace.Entity:IsValid() or not self:GetOwner():IsAdmin() then return end

	local ent = trace.Entity
	local ply = self:GetOwner()

	if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end
	if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
	if ent.PermaProps then ply:ChatPrint( "That entity is already permanent !" ) return end

	local content = duplicator.CopyEntTable( ent )
	content.Constraints = {} -- No Constraints :)
	content.ConstraintSystem = {} -- No Constraints :)

	ent:Remove()

	local new_ent = duplicator.CreateEntityFromTable(nil, content)
	new_ent.ID = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;")) or 1
	new_ent.PermaProps = true
	new_ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	new_ent:SetMoveType(0)

	local effectdata = EffectData()
	effectdata:SetOrigin(ent:GetPos())
	effectdata:SetMagnitude(2)
	effectdata:SetScale(2)
	effectdata:SetRadius(3)
	util.Effect("Sparks", effectdata)

	sql.Query("INSERT INTO permaprops (id, map, content) VALUES(NULL, ".. sql.SQLStr(game.GetMap()) ..", ".. sql.SQLStr(util.TableToJSON(content)) ..");")
	ply:ChatPrint("You saved " .. ent:GetClass() .. " with model ".. ent:GetModel() .. " to the database.")

	return true

end

function TOOL:RightClick(trace)

	if (CLIENT) then return end

	if (not trace.Entity:IsValid()) then return end

	local ent = trace.Entity
	local ply = self:GetOwner()

	if not ply:IsAdmin() then return end
	if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end
	if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
	if not ent.PermaProps then ply:ChatPrint( "That is not a PermaProp !" ) return end
	if not ent.ID then ply:ChatPrint( "ERROR: ID not found" ) return end
	
	ent:Remove()

	sql.Query("DELETE FROM permaprops WHERE id = ".. ent.ID ..";")

	ply:ChatPrint("You erased " .. ent:GetClass() .. " with a model of " .. ent:GetModel() .. " from the database.")

	return true

end

function TOOL:Reload(trace)

	if (CLIENT) then return end

	if (not trace.Entity:IsValid()) then self:GetOwner():ChatPrint( "You have reload all PermaProps !" ) ReloadPermaProps() return false end

	if trace.Entity.PermaProps then

		local ent = trace.Entity
		local ply = self:GetOwner()

		if not ply:IsAdmin() then return end
		if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
		
		local content = duplicator.CopyEntTable( ent )
		content.Constraints = {} -- No Constraints :)
		content.ConstraintSystem = {} -- No Constraints :)

		local new_ent = duplicator.CreateEntityFromTable(nil, content)
		new_ent.ID = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;")) or 1
		new_ent.PermaProps = true
		new_ent:SetRenderMode( RENDERMODE_TRANSALPHA )
		new_ent:SetMoveType(0)

		ent:Remove()

		local effectdata = EffectData()
		effectdata:SetOrigin(ent:GetPos())
		effectdata:SetMagnitude(2)
		effectdata:SetScale(2)
		effectdata:SetRadius(3)
		util.Effect("Sparks", effectdata)

		sql.Query("UPDATE permaprops set content = ".. sql.SQLStr(util.TableToJSON(content)) .." WHERE id = ".. ent.ID .." AND map = ".. sql.SQLStr(game.GetMap()) .. ";")
		ply:ChatPrint("You updated the " .. ent:GetClass() .. " you selected in the database.")


	else

		return false

	end

	return true

end

function TOOL.BuildCPanel(panel)

	panel:AddControl("Header",{Text = "PermaProps", Description = "Save a props for server restarts\nBy Malboro"})
	panel:AddControl("Label",{Text = "------ Configuration ------"})
	panel:AddControl("Button",{Label = "Admin can touch PermaProps", Command = "pp_phys_change_admin"})
	panel:AddControl("Button",{Label = "SuperAdmin can touch PermaProps", Command = "pp_phys_change_sadmin"})
	panel:AddControl("Label",{Text = "-------- Functions --------"})
	panel:AddControl("Button", {Text = "Remove all PermaProps", Command = "perma_remove_all"})

end

local function PermaRemoveAll( ply )

	if CLIENT then return end

	if not ply:IsAdmin() then return end

	sql.Query("DELETE FROM permaprops WHERE map = ".. sql.SQLStr(game.GetMap()) ..";")

	ply:ChatPrint("You erased all props from the map")

	ReloadPermaProps()

end
concommand.Add("perma_remove_all", PermaRemoveAll)

local function pp_phys_change_admin( ply ) -- Shit but work !!

	if CLIENT then return end

	if not ply:IsSuperAdmin() then return end

	local Value = (GetConVarNumber("pp_phys_admin") or 0)

	if Value == 1 then
		game.ConsoleCommand("pp_phys_admin 0\n")
		ply:ChatPrint("Admin can't touch permaprops !")
	elseif Value == 0 then
		game.ConsoleCommand("pp_phys_admin 1\n")
		ply:ChatPrint("Admin can touch permaprops !")
	end

end
concommand.Add("pp_phys_change_admin", pp_phys_change_admin)

local function pp_phys_change_sadmin( ply ) -- Shit but work !!

	if CLIENT then return end

	if not ply:IsSuperAdmin() then return end

	local Value = (GetConVarNumber("pp_phys_sadmin") or 0)

	if Value == 1 then
		game.ConsoleCommand("pp_phys_sadmin 0\n")
		ply:ChatPrint("SuperAdmin can't touch permaprops !")
	elseif Value == 0 then
		game.ConsoleCommand("pp_phys_sadmin 1\n")
		ply:ChatPrint("SuperAdmin can touch permaprops !")
	end

end
concommand.Add("pp_phys_change_sadmin", pp_phys_change_sadmin)

local function PermaPropsPhys( ply, ent )

	if CLIENT then return end

	if ent.PermaProps == true then

		if ply:IsAdmin() and GetConVarNumber("pp_phys_admin") == 1 then

			return true

		elseif ply:IsSuperAdmin() and GetConVarNumber("pp_phys_sadmin") == 1 then

			return true

		else

			return false

		end

	end
	
end
hook.Add("PhysgunPickup", "PermaPropsPhys", PermaPropsPhys)