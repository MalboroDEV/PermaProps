/*
   ____          _          _   ____          __  __       _ _                     
  / ___|___   __| | ___  __| | | __ ) _   _  |  \/  | __ _| | |__   ___  _ __ ___  
 | |   / _ \ / _` |/ _ \/ _` | |  _ \| | | | | |\/| |/ _` | | '_ \ / _ \| '__/ _ \ 
 | |__| (_) | (_| |  __/ (_| | | |_) | |_| | | |  | | (_| | | |_) | (_) | | | (_) |
  \____\___/ \__,_|\___|\__,_| |____/ \__, | |_|  |_|\__,_|_|_.__/ \___/|_|  \___/ 
                                      |___/                                        
*/

function PermaPropsULX()

	if ULib and ULib.ucl then

		ULib.ucl.registerAccess( "permaprops_tool", ULib.ACCESS_ADMIN, "Ability to use tool en perma props", "PermaProps" )
		ULib.ucl.registerAccess( "permaprops_phys", ULib.ACCESS_ADMIN, "Ability to phys perma props", "PermaProps" )
		ULib.ucl.registerAccess( "permaprops_property", ULib.ACCESS_ADMIN, "Ability to property perma props", "PermaProps" )
		ULib.ucl.registerAccess( "permaprops_save", ULib.ACCESS_ADMIN, "Ability to save props", "PermaProps" )
		ULib.ucl.registerAccess( "permaprops_delete", ULib.ACCESS_ADMIN, "Ability to delete perma props", "PermaProps" )
		ULib.ucl.registerAccess( "permaprops_update", ULib.ACCESS_ADMIN, "Ability to update perma props", "PermaProps" )
		ULib.ucl.registerAccess( "permaprops_menu", ULib.ACCESS_ADMIN, "Ability to open the menu", "PermaProps" )

	end

end
hook.Add( "InitPostEntity", "PermaPropsULX", PermaPropsULX )