/*
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
*/

print("-------------------------------")
print("Loading ServerSide PermaProps")
include("permaprops/sv_lib.lua")
include("permaprops/sv_specialfcn.lua")
include("permaprops/sv_sql.lua")
include("permaprops/sv_permissions.lua")
include("permaprops/sv_menu.lua")
print("Loading ClientSide PermaProps")
AddCSLuaFile("permaprops/cl_menu.lua")
AddCSLuaFile("permaprops/cl_drawent.lua")
print("PermaProps Loaded !")
print("-------------------------------")