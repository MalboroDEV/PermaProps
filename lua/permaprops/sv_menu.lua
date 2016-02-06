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

	if !file.Exists( "permaprops_config.txt", "DATA" )  then
		
		local NewData = {}
		NewData.PhysSA = true
		NewData.PhysA = false
		NewData.ToolSA = true
		NewData.ToolA = false
		NewData.PropA = false
		NewData.PropSA = false

		 PermaProps.Permissions["PhysSA"] = true
		PermaProps.Permissions["PhysA"] = false
		PermaProps.Permissions["ToolSA"] = true
		PermaProps.Permissions["ToolA"] = false
		PermaProps.Permissions["PropA"] = false
		PermaProps.Permissions["PropSA"] = false

		file.Write( "permaprops_config.txt", util.TableToJSON(NewData) ) 

	else

 		local content = file.Read( "permaprops_config.txt" )
 		local data = util.JSONToTable( content )
 		PermaProps.Permissions["PhysSA"] = data.PhysSA
		PermaProps.Permissions["PhysA"] = data.PhysA
		PermaProps.Permissions["ToolSA"] = data.ToolSA
		PermaProps.Permissions["ToolA"] = data.ToolA
		PermaProps.Permissions["PropA"] = data.ToolA
		PermaProps.Permissions["PropSA"] = data.ToolA

	end

end
PermissionLoad()

local function PermissionSave()

	local NewData = {}
	NewData.PhysSA = PermaProps.Permissions["PhysSA"]
	NewData.PhysA = PermaProps.Permissions["PhysA"]
	NewData.ToolSA = PermaProps.Permissions["ToolSA"]
	NewData.ToolA = PermaProps.Permissions["ToolA"]
	NewData.PropA = PermaProps.Permissions["PropA"]
	NewData.PropSA = PermaProps.Permissions["PropSA"]

	file.Write( "permaprops_config.txt", util.TableToJSON(NewData) ) 

end

local function pp_open_menu( ply )

	if !ply:IsAdmin() then return end

	local SendTable = {}
	local Data_PropsList = sql.Query( "SELECT * FROM permaprops WHERE map = ".. sql.SQLStr(game.GetMap()) .. ";" )

	if Data_PropsList then
	
		for k, v in pairs( Data_PropsList ) do

			local data = util.JSONToTable(v.content)

			SendTable[v.id] = {Model = data.Model, Class = data.Class, Pos = data.Pos, Angle = data.Angle}

		end

	end

	local Content = {}
	Content.MProps = tonumber(sql.QueryValue("SELECT COUNT(*) FROM permaprops WHERE map = ".. sql.SQLStr(game.GetMap()) .. ";"))
	Content.TProps = tonumber(sql.QueryValue("SELECT COUNT(*) FROM permaprops;"))
	Content.PhysSA = PermaProps.Permissions["PhysSA"]
	Content.PhysA = PermaProps.Permissions["PhysA"]
	Content.ToolSA = PermaProps.Permissions["ToolSA"]
	Content.ToolA = PermaProps.Permissions["ToolA"]
	Content.PropA = PermaProps.Permissions["PropA"]
	Content.PropSA = PermaProps.Permissions["PropSA"]
	Content.PropsList = SendTable

	net.Start( "pp_open_menu" )
	net.WriteTable( Content )
	net.Send( ply )

end
concommand.Add("pp_cfg_open", pp_open_menu)

local function pp_info_send( um, ply )

	local Content = net.ReadTable()

	if !ply:IsSuperAdmin() then ply:ChatPrint("Access denied for user") return end

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

	end

end
net.Receive("pp_info_send", pp_info_send)