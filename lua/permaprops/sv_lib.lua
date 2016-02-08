/*
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
*/

if not PermaProps then PermaProps = {} end

function PermaProps.PPGetEntTable( ent )

	if !ent or !ent:IsValid() then return false end

	local content = {}
	content.Class = ent:GetClass()
	content.Pos = ent:GetPos()
	content.Angle = ent:GetAngles()
	content.Model = ent:GetModel()
	content.Skin = ent:GetSkin()
	//content.Mins, content.Maxs = ent:GetCollisionBounds()
	content.ColGroup = ent:GetCollisionGroup()
	content.Name = ent:GetName()
	content.ModelScale = ent:GetModelScale()
	content.Color = ent:GetColor()
	content.Material = ent:GetMaterial()
	content.Solid = ent:GetSolid()
	
	if PermaProps.SpecialENTSSave[ent:GetClass()] != nil and isfunction(PermaProps.SpecialENTSSave[ent:GetClass()]) then

		local othercontent = PermaProps.SpecialENTSSave[ent:GetClass()](ent)
		if not othercontent then return false end
		if othercontent != nil and istable(othercontent) then
			table.Merge(content, othercontent)
		end

	end

	if ( ent.GetNetworkVars ) then
		content.DT = ent:GetNetworkVars()
	end

	if ent:GetPhysicsObject() and ent:GetPhysicsObject():IsValid() then
		content.Frozen = !ent:GetPhysicsObject():IsMoveable()
	end

	return content

end

function PermaProps.PPEntityFromTable( data, id )

	if not id or not isnumber(id) then return false end

	local ent = ents.Create(data.Class)
	if !ent then return false end
	if !ent:IsVehicle() then if !ent:IsValid() then return false end end
	ent:SetPos( data.Pos or Vector(0, 0, 0) )
	ent:SetAngles( data.Angle or Angle(0, 0, 0) )
	ent:SetModel( data.Model or "models/error.mdl" )
	ent:SetSkin( data.Skin or 0 )
	//ent:SetCollisionBounds( ( data.Mins or 0 ), ( data.Maxs or 0 ) )
	ent:SetCollisionGroup( data.ColGroup or 0 )
	ent:SetName( data.Name or "" )
	ent:SetModelScale( data.ModelScale or 1 )
	ent:SetMaterial( data.Material or "" )
	ent:SetSolid( data.Solid or 6 )

	if PermaProps.SpecialENTSSpawn[data.Class] != nil and isfunction(PermaProps.SpecialENTSSpawn[data.Class]) then

		PermaProps.SpecialENTSSpawn[data.Class](ent, data.Other)

	else

		ent:Spawn()

	end

	ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	ent:SetColor( data.Color or Color(255, 255, 255, 255) )

	if data.EntityMods != nil and istable(data.EntityMods) then -- OLD DATA

		if data.EntityMods.material then
			ent:SetMaterial( data.EntityMods.material["MaterialOverride"] or "")
		end
		
		if data.EntityMods.colour then
			ent:SetColor( data.EntityMods.colour.Color or Color(255, 255, 255, 255))
		end

	end

	if data.DT then

		for k, v in pairs( data.DT ) do

			if ( data.DT[ k ] == nil ) then continue end
			if !isfunction(ent[ "Set" .. k ]) then continue end
			ent[ "Set" .. k ]( ent, data.DT[ k ] )

		end

	end

	ent.PermaProps_ID = id
	ent.PermaProps = true

	if data.Frozen != nil then
		
		local phys = ent:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion(!data.Frozen)
		end

	end

	return ent

end

function PermaProps.ReloadPermaProps()

	for k, v in pairs( ents.GetAll() ) do

		if v.PermaProps == true then

			v:Remove()

		end

	end

	local content = PermaProps.SQL.Query( "SELECT * FROM permaprops WHERE map = ".. sql.SQLStr(game.GetMap()) .. ";" )

	if not content or content == nil then return end
	
	for k, v in pairs( content ) do

		local data = util.JSONToTable(v.content)

		local e = PermaProps.PPEntityFromTable(data, tonumber(v.id))
		if !e or !e:IsValid() then continue end

	end

end
hook.Add("InitPostEntity", "InitializePermaProps", PermaProps.ReloadPermaProps)
hook.Add("PostCleanupMap", "WhenCleanUpPermaProps", PermaProps.ReloadPermaProps) -- #MOMO

function PermaProps.SparksEffect( ent )

	local effectdata = EffectData()
	effectdata:SetOrigin(ent:GetPos())
	effectdata:SetMagnitude(2)
	effectdata:SetScale(2)
	effectdata:SetRadius(3)
	util.Effect("Sparks", effectdata)

end