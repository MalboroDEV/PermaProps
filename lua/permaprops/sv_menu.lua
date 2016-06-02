/*
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
*/

util.AddNetworkString("pp_open_menu")
util.AddNetworkString("pp_info_send")

local function PermissionLoad()

	if not PermaProps then PermaProps = {} end
	if not PermaProps.Permissions then PermaProps.Permissions = {} end

	PermaProps.Permissions["PhysSA"] = true
	PermaProps.Permissions["PhysA"] = false

	PermaProps.Permissions["ToolSA"] = true
	PermaProps.Permissions["ToolA"] = false
	
	PermaProps.Permissions["PropA"] = false
	PermaProps.Permissions["PropSA"] = false

	PermaProps.Permissions["ToolSaveA"] = true
	PermaProps.Permissions["ToolSaveSA"] = true

	PermaProps.Permissions["ToolDelA"] = true
	PermaProps.Permissions["ToolDelSA"] = true

	PermaProps.Permissions["ToolUpdtA"] = true
	PermaProps.Permissions["ToolUpdtSA"] = true

	PermaProps.Permissions["ULXMod"] = false

	if file.Exists( "permaprops_config.txt", "DATA" )  then

 		local content = file.Read( "permaprops_config.txt" )

 		table.Merge(PermaProps.Permissions, ( util.JSONToTable( content ) or {} ))

	end

end
PermissionLoad()

local function PermissionSave()

	file.Write( "permaprops_config.txt", util.TableToJSON(PermaProps.Permissions) ) 

end

local function pp_open_menu( ply )

	if !PermaProps.IsAdmin(ply) then return end

	local SendTable = {}
	local Data_PropsList = sql.Query( "SELECT * FROM permaprops WHERE map = ".. sql.SQLStr(game.GetMap()) .. ";" )

	if Data_PropsList and #Data_PropsList < 500 then
	
		for k, v in pairs( Data_PropsList ) do

			local data = util.JSONToTable(v.content)

			SendTable[v.id] = {Model = data.Model, Class = data.Class, Pos = data.Pos, Angle = data.Angle}

		end

	elseif Data_PropsList and #Data_PropsList > 500 then -- Too much props dude :'(

		for i = 1, 499 do
			
			local data = util.JSONToTable(Data_PropsList[i].content)

			SendTable[Data_PropsList[i].id] = {Model = data.Model, Class = data.Class, Pos = data.Pos, Angle = data.Angle}

		end

	end

	local Content = {}
	Content.MProps = tonumber(sql.QueryValue("SELECT COUNT(*) FROM permaprops WHERE map = ".. sql.SQLStr(game.GetMap()) .. ";"))
	Content.TProps = tonumber(sql.QueryValue("SELECT COUNT(*) FROM permaprops;"))

	table.Merge(Content, PermaProps.Permissions)

	Content.PropsList = SendTable

	net.Start( "pp_open_menu" )
	net.WriteTable( Content )
	net.Send( ply )

end
concommand.Add("pp_cfg_open", pp_open_menu)

local function pp_info_send( um, ply )

	local Content = net.ReadTable()

	if !PermaProps.IsSuperAdmin(ply) then ply:ChatPrint("Access denied for user") return end

	if Content["CMD"] == "DEL" then

		Content["Val"] = tonumber(Content["Val"])

		if Content["Val"] != nil and Content["Val"] <= 0 then return end

		sql.Query("DELETE FROM permaprops WHERE id = ".. sql.SQLStr(Content["Val"]) .. ";")

		for k, v in pairs(ents.GetAll()) do
			
			if v.PermaProps_ID == Content["Val"] then

				ply:ChatPrint("You erased " .. v:GetClass() .. " with a model of " .. v:GetModel() .. " from the database.")
				v:Remove()
				break

			end

		end

	elseif Content["CMD"] == "VAR" then

		if PermaProps.Permissions[Content["Data"]] == nil then return end
		if !isbool(Content["Val"]) then return end

		PermaProps.Permissions[Content["Data"]] = Content["Val"]

		PermissionSave()

	elseif Content["CMD"] == "DEL_MAP" then

		sql.Query( "DELETE FROM permaprops WHERE map = ".. sql.SQLStr(game.GetMap()) .. ";" )
		PermaProps.ReloadPermaProps()

		ply:ChatPrint("You erased all props from the map !")

	elseif Content["CMD"] == "DEL_ALL" then

		sql.Query( "DELETE FROM permaprops;" )
		PermaProps.ReloadPermaProps()

		ply:ChatPrint("You erased all props !")

	elseif Content["CMD"] == "CLR_MAP" then

		for k, v in pairs( ents.GetAll() ) do

			if v.PermaProps == true then

				v:Remove()

			end

		end

		ply:ChatPrint("You have removed all props !")

	end

end
net.Receive("pp_info_send", pp_info_send)