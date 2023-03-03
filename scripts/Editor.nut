/*
	- 	► Anik's GUI Editor
	- 	► Thanks to Doom for his map editor. The GUI Editor is made by modifying the Map Editor.
	- 	► Thanks to vito for giving the idea of editing object with mouse and helping with the ratio.
	
	- 	► Known Bugs
	- 	
	- 	► Sometimes clicking on the element doesn't select the element. In this case use /selectelement command.
	- 	► Clicking on button selects the element but you will not able to use any command. Use /selectelement 
		command if u need to use any command while editing any button.
	- 	► Using ":" or "'" or """ in text or element may not work. You shouldn't use those characters in your text.
	
	-    Changelog - v1.1
	-    ► Fixed AddChild bug.
	-    ► Fixed the game crash while adding child.
*/

SetServerName("Anik's GUI Editor [v1.0]");

function onScriptLoad()
{
	// =========================================== File ==============================================
	dofile( "scripts/FileHandler.addon", true );
	// =========================================== DATABASE ============================================
	Projects <- ConnectSQL( "scripts/Projects.sqlite" );	
	// =========================================== GLOBAL ==============================================
	CurrentProject <- "";
	ElementCreated <- 0;
	ProjectLoaded <- array( GetMaxPlayers(), 0 );
	// =========================================== PRINTS ==============================================
	print( "Anik's GUI Editor successfully started!" );
	print( "Editor successfully running! ");
}
// =========================================== PLAYER EVENTS ===========================================

function onPlayerJoin( player )
{
	MessagePlayer( "[#ffffff][Server]: [#00CC00]Welcome to Anik's GUI Editor!", player );
	ProjectLoaded[ player.ID ] = false;
}

function onPlayerSpawn( player )
{	
	player.Pos = Vector( -335.591, -524.865, 12.7615 );
	player.Immunity = 31;
	
	MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]These are the keys used to interact with the editor!", player );
	MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]Click on any element or use /selectelement to start editing any element.", player );
	MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]Page UP | DOWN - Increase/Decrease fontsize.", player );
	MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]R - Switch between Resizing & Position Mode | You can also hold RMB and move your mouse to resize your element", player );
	MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]C - Switch between R/G/B while colour mode is enabled", player );
	MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]Backspace - Stop controlling an element. You can also click anywhere in the game to stop controlling an element", player );
	MessagePlayer( "[#00CC00][CMDS]: [#FFFFFF]Use /cmds for a list of commands", player );
	
	if( CurrentProject != "" && !ProjectLoaded[ player.ID ] )
	{
		local Project, q, childs, elementcount, childscount = 0;
		try
		{
			Project = QuerySQL( Projects, "SELECT * FROM '" + CurrentProject.tolower() + "'" );
			q = QuerySQL( Projects, "SELECT COUNT(*) FROM '" + CurrentProject.tolower() + "'" );
			elementcount = GetSQLColumnData( q, 0 );
			childs = array( elementcount + 1, 0 );
		}
		catch( e ) return;
		do
		{
			local id = GetSQLColumnData( Project, 0 ),
			 model = GetSQLColumnData( Project, 1 ),
			 name = GetSQLColumnData( Project, 2 ),
			 x = GetSQLColumnData( Project, 3 ),
			 y = GetSQLColumnData( Project, 4 ),
			 sizex = GetSQLColumnData( Project, 5 ),
			 sizey = GetSQLColumnData( Project, 6 ),
			 childof = GetSQLColumnData( Project, 7 ),
			 txt = GetSQLColumnData( Project, 8 ),
			 fontsize = GetSQLColumnData( Project, 9 ),
			 colour = GetSQLColumnData( Project, 10 ), 
			 txtcolour = GetSQLColumnData( Project, 11 );
				ElementCreated++;
				SendDataToClient( player, 6, id+":"+model+":"+name+":"+x+":"+y+":"+sizex+":"+sizey+":"+childof+":"+txt+":"+fontsize+":"+colour+":"+txtcolour );
				if( childof != "none" )
				{
					local qq = QuerySQL( Projects, "SELECT * FROM '" + CurrentProject.tolower() + "' WHERE name = '"+childof+"'" );
					childs[childscount] = GetSQLColumnData( qq, 0 )+":"+id;
					childscount++;
					FreeSQLQuery( qq );
				}
				if( ElementCreated == elementcount )
				{
					if( childscount > 0 )
					{
						local i = 0;
						while( i != childscount )
						{
							SendDataToClient( player, 5, childs[i] );
							i++;
							print( i );
						}
					}
				}
			}
			while ( GetSQLNextRow( Project ) );
			FreeSQLQuery( q );
			FreeSQLQuery( Project );
			ProjectLoaded[ player.ID ] = true;
			SendDataToClient( player, 11, CurrentProject );
		}		
	}


function onClientScriptData( player )
{
	local int = Stream.ReadInt(),
		str = Stream.ReadString();
	switch( int )
	{
		case 1://We have finished editing the object, so we should save it in our database
		
			local data = split( str, ":" );
			QuerySQL( Projects, "UPDATE "+CurrentProject.tolower()+" SET x = '"+data[1].tofloat()+"', y = '"+data[2].tofloat()+"', SizeX = '"+data[3].tofloat()+"', SizeY = '"+data[4].tofloat()+"', txt = '"+data[6]+"', FontSize = '"+data[5]+"', Colour = '"+data[7]+"', TextColour = '"+data[8]+"' WHERE id = '"+data[0].tointeger()+"'");
		
		break;
		
		case 2://Streaming to all players
			local data = split( str, ":" ),
			 action = data[0];
			if( action == "pos" )
			{
				SendDataToClient( null, 12, action+":"+data[1]+":"+data[2]+":"+data[3] );
			}
			else if ( action == "size" )
			{
				SendDataToClient( null, 12, action+":"+data[1]+":"+data[2]+":"+data[3] );
			}
			else if ( action == "col" )
			{
				SendDataToClient( null, 12, action+":"+data[1]+":"+data[2] );
			}
			else if ( action == "txtcol" )
			{
				SendDataToClient( null, 12, action+":"+data[1]+":"+data[2] );
			}
			else if ( action == "font" )
			{
				SendDataToClient( null, 12, action+":"+data[1]+":"+data[2] );
			}
		
		break;
	}
}

function onPlayerCommand( player, cmd, text )
{
	if( cmd == "newpro" || cmd == "newproj" || cmd == "newproject" )
	{
		if( text && CurrentProject == "" )
		{
			if( text == "default" ) return MessagePlayer( "[#00CC00][ERROR]: [#FFFFFF]The name [#00CC00]default [#FFFFFF]cannot be used to create a map", player );
			local check_project;
			try { check_project = QuerySQL( Projects, "SELECT * FROM sqlite_master WHERE type='table' AND name='" + CurrentProject.tolower() + "'"); } catch( e ) return MessagePlayer( "[#00CC00][MAP]: [#ffffff]A project with that name already exists!", player );
			QuerySQL( Projects, "CREATE TABLE '" + text.tolower() + "'( id TEXT, model TEXT, name TEXT, x FLOAT, y FLOAT, SizeX FLOAT, SizeY FLOAT, childof TEXT, txt TEXT, FontSize TEXT, Colour VARCHAR(15), TextColour VARCHAR(15) )" );
			CurrentProject = text;
			Message( "[#ffffff][New-Project]: [#00CC00]A new project [#ffffff]" + CurrentProject + " [#00CC00]was started by [#ffffff]" + player.Name + "." );
			if( check_project != null ) FreeSQLQuery( check_project );
			SendDataToClient( null , 11, CurrentProject );
		}
		else if( text && CurrentProject != "" )
		{ 
			Message( "[#00CC00][NEWPROJECT]: [#ffffff]The PROJECT [#00CC00]" + CurrentProject + " [#ffffff]is still loaded, please close this project before proceeding. /savemap to save & close!" );
		}
	}
	
	else if ( cmd == "help" )
	{
		MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]These are the keys used to interact with the editor!", player );
		MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]Click on any element or use /selectelement to start editing any element.", player );
		MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]Page UP | DOWN - Increase/Decrease fontsize.", player );
		MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]R - Switch between Resizing & Position Mode | You can also hold RMB and move your mouse to resize your element", player );
		MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]C - Switch between R/G/B while colour mode is enabled", player );
		MessagePlayer( "[#00CC00][KEYS]: [#FFFFFF]Backspace - Stop controlling an element. You can also click anywhere in the game to stop controlling an element", player );
	}
	
	else if ( cmd == "cmds" || cmd == "command" || cmd == "commands" )
	{
		MessagePlayer( "[#00CC00][Commands]: [#FFFFFF]/editelement , /addchild, /addlabel, /addwindow, /closeproject, /saveproject, /exportproject, /deleteproject, /projects, /elements, /changetext, /changetextcolor, /changecolour", player );
	}
	
	else if( cmd == "selectelement" || cmd == "editelement" )
	{
		if( !text ) return MessagePlayer( "[#00CC00][ERROR]: [#FFFFFF]/" + cmd + " [Element Name]", player );
		local q = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower()+" WHERE name = '"+text+"' COLLATE NOCASE");
		if( !q ) 
		{	
			MessagePlayer( "[#00CC00][Element]: [#ffffff]There is no such element "+text.tolower(), player );
			FreeSQLQuery( q );
			return;
		}
		else 
		{
			SendDataToClient( player , 3, text+":"+GetSQLColumnData( q, 0 ) );
			MessagePlayer( "[#00CC00][Help]: [#ffffff]Use arrow keys to change the position of your element. Use PageUP/PageDown to increase/decrease the fontsize of your element.", player );
			MessagePlayer( "[#00CC00][Help]: [#ffffff]Press R to enable resize mode..", player );
			FreeSQLQuery( q );
		}	
	}

	else if ( cmd == "changetext" || cmd == "settext" )
	{
		if( !text ) return MessagePlayer( "[#00CC00][ERROR]: [#FFFFFF]/" + cmd + " [ text ]", player );
		SendDataToClient( player, 8, text );
	}
	
	else if( cmd == "addchild" )
	{
		if( !text ) return MessagePlayer( "[#00CC00][ERROR]: [#FFFFFF]/" + cmd + " <element> <child of element>", player );
		local element = GetTok( text, " ", 1 ), childelement = GetTok( text, " ", 2 ),
		q = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower()+" WHERE name = '"+element+"' COLLATE NOCASE"),
		qq = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower()+" WHERE name = '"+childelement+"' COLLATE NOCASE");
		if( !q ) 
		{	
			MessagePlayer( "[#00CC00][Element]: [#ffffff]There is no such element "+element, player );
			FreeSQLQuery( q );
			FreeSQLQuery( qq );
			return;
		}
		else if( !qq ) 
		{
			MessagePlayer( "[#00CC00][Element]: [#ffffff]There is no such element "+childelement, player );
			FreeSQLQuery( q );
			FreeSQLQuery( qq );
			return;
		}
		else 
		{
			SendDataToClient( null, 12, "addchild:"+GetSQLColumnData( qq, 0 )+":"+GetSQLColumnData( q, 0 ) );
			SendDataToClient( player, 5, GetSQLColumnData( qq, 0 )+":"+GetSQLColumnData( q, 0 ) );			
			QuerySQL( Projects, "UPDATE "+CurrentProject.tolower()+" SET childof = '"+GetSQLColumnData( qq, 2 )+"' WHERE name = '"+GetSQLColumnData( q, 2 )+"'");
			Message( "[#ffffff]"+element+" is now a child of "+childelement );
			FreeSQLQuery( q );
			FreeSQLQuery( qq );
		}	
	}
	
	else if( cmd == "addlabel" )
	{
		if( CurrentProject == "" ) return MessagePlayer( "[#00CC00][Project]: [#ffffff]You must open a project to add labels!", player );
		if( text && NumTok( text, " " ) > 1 )
		{
			local namee = GetTok( text, " ", 1 ), txt = GetTok( text, " ", 2, NumTok( text, " " ) ),			
			q = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower()+" WHERE name = '"+namee+"' COLLATE NOCASE");
			if( namee == CurrentProject ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]There is a project named "+namee, player );
			else if( IsNum( namee) ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]Name of element can not be numbers.", player );
			else if( q ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]There is already a "+GetSQLColumnData( q, 1 )+" named "+namee, player );
			else QuerySQL( Projects, "INSERT INTO "+CurrentProject.tolower()+" ( id, model, name, x, y, SizeX, SizeY, childof, txt, FontSize, Colour, TextColour ) VALUES ( '"+ElementCreated+"', 'GUILabel', '"+namee+"', 0, 0, 0.5, 0.5, 'none', '"+txt+"', 11, '50,50,50', '255,255,255' )");
			player.Pos.z += 3;
			SendDataToClient( player, 2, ElementCreated+":"+txt );
			SendDataToClient( null, 12, "addlabel:"+ElementCreated+":"+txt );
			Message( "[#00CC00][Project]: [#ffffff]Created Label " + namee );
			MessagePlayer( "[#00CC00][Help]: [#ffffff]Use arrow keys to change the position of your element. Use PageUP/PageDown to increase/decrease the fontsize of your element.", player );
			ElementCreated++;
		}
		else MessagePlayer( "[#00CC00][SYNTAX]: [#ffffff]/"+cmd+" <name of label> <text>", player );
	}
	
	else if( cmd == "addwindow" )
	{
		if( CurrentProject == "" ) return MessagePlayer( "[#00CC00][Project]: [#ffffff]You must open a project to add windows!", player );
		if( text && NumTok( text, " " ) > 1 )
		{
			local namee = GetTok( text, " ", 1 ), txt = GetTok( text, " ", 2, NumTok( text, " " ) ),			
			q = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower()+" WHERE name = '"+namee+"' COLLATE NOCASE");
			if( namee == CurrentProject ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]There is a project named "+namee, player );
			else if( IsNum( namee) ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]Name of element can not be numbers.", player );
			else if( q ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]There is already a "+GetSQLColumnData( q, 1 )+" named "+namee, player );
			else QuerySQL( Projects, "INSERT INTO "+CurrentProject.tolower()+" ( id, model, name, x, y, SizeX, SizeY, childof, txt, FontSize, Colour, TextColour ) VALUES ( '"+ElementCreated+"', 'GUIWindow', '"+namee+"', 0, 0, 0.5, 0.5, 'none', '"+txt+"', 11, '50,50,50', '255,255,255' )");
			player.Pos.z += 3;
			SendDataToClient( player, 4, ElementCreated+":"+txt );
			SendDataToClient( null, 12, "addwin:"+ElementCreated+":"+txt );
			Message( "[#00CC00][Project]: [#ffffff]Created Window " + namee );
			MessagePlayer( "[#00CC00][Help]: [#ffffff]Use arrow keys to change the position of your element. Use PageUP/PageDown to increase/decrease the fontsize of your element.", player );
			MessagePlayer( "[#00CC00][Help]: [#ffffff]Press R to enable resize mode..", player );
			ElementCreated++;
		}
		else MessagePlayer( "[#00CC00][SYNTAX]: [#ffffff]/"+cmd+" <name of window> <text>", player );
	}
	
	else if ( cmd == "addbutton" )
	{
		if( CurrentProject == "" ) return MessagePlayer( "[#00CC00][Project]: [#ffffff]You must open a project to add windows!", player );
		if( text && NumTok( text, " " ) > 1 )
		{
			local namee = GetTok( text, " ", 1 ), txt = GetTok( text, " ", 2, NumTok( text, " " ) ),
			q = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower()+" WHERE name = '"+namee+"' COLLATE NOCASE");
			if( namee == CurrentProject ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]There is a project named "+namee, player );
			else if( IsNum( namee) ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]Name of element can not be numbers.", player );
			else if( q ) return MessagePlayer( "[#00CC00][Error]: [#ffffff]There is already a "+GetSQLColumnData( q, 1 )+" named "+namee, player );
			else QuerySQL( Projects, "INSERT INTO "+CurrentProject.tolower()+" ( id, model, name, x, y, SizeX, SizeY, childof, txt, FontSize, Colour, TextColour ) VALUES ( '"+ElementCreated+"', 'GUIButton', '"+namee+"', 0, 0, 0.5, 0.5, 'none', '"+txt+"', 11, '50,50,50', '255,255,255' )");
			player.Pos.z += 3;
			SendDataToClient( player, 9, ElementCreated+":"+txt );
			SendDataToClient( null, 12, "addbutton:"+ElementCreated+":"+txt );
			Message( "[#00CC00][Project]: [#ffffff]Created Window " + namee );
			MessagePlayer( "[#00CC00][Help]: [#ffffff]Use arrow keys to change the position of your element. Use PageUP/PageDown to increase/decrease the fontsize of your element.", player );
			MessagePlayer( "[#00CC00][Help]: [#ffffff]Press R to enable resize mode..", player );
			ElementCreated++;
		}
		else MessagePlayer( "[#00CC00][SYNTAX]: [#ffffff]/"+cmd+" <name of button> <text>", player );
	}
	
	else if ( cmd == "changecolor" || cmd == "changecolour" )
	{
		SendDataToClient( player, 10, "" );
	}
	else if ( cmd == "changetxtcolor" || cmd == "changetxtcolour" || cmd == "changetextcolour" || cmd == "changetextcolor" )
	{
		SendDataToClient( player, 10, "" );
	}
	
	else if( cmd == "project" )
	{
		if( CurrentProject != "" ) Message( "[#00CC00][PROJECT]: [#ffffff]" + CurrentProject );
		else Message( "[#00CC00][PROJECT]: [#ffffff]None" );
	}
	

	else if( cmd == "saveproject" )
	{
		if( CurrentProject != "" )
		{
			if( ElementCreated == 0 )
			{
				QuerySQL( Projects, "DROP TABLE " + CurrentProject.tolower() + "" );
				CurrentProject = "";
				return MessagePlayer( "[#ffffff][Project]: [#00CC00]The project has been [#ffffff]closed & deleted [#00CC00]as no element were created.", player );
			}
			SendDataToClient( null, 7, "" );
			Message( "[#00CC00][PROJECT]: [#ffffff]" + player.Name + " has saved the project" );
		}
	}
	
	else if( cmd == "closeproject" )
	{
		if( CurrentProject != "" )
		{
			if( ElementCreated == 0 )
			{
				QuerySQL( Projects, "DROP TABLE " + CurrentProject.tolower() );
				CurrentProject = "";
				return MessagePlayer( "[#ffffff][Project]: [#00CC00]The project has been [#ffffff]closed & deleted [#00CC00]as no elements were created.", player );
			}
			SendDataToClient( null, 7, "" );
			SendDataToClient( null, 1, "" );
			CurrentProject = "";
			ElementCreated = 0;
			Message( "[#00CC00][PROJECT]: [#ffffff]" + player.Name + " has closed the project" );
		}
	}
	
	else if( cmd == "exportproject" )
	{
		if( CurrentProject != "" )
		{
			if( ElementCreated == 0 )
			{
				QuerySQL( Projects, "DROP TABLE " + CurrentProject.tolower() + "" );
				CurrentProject = "";
				return MessagePlayer( "[#ffffff][PROJECT]: [#00CC00]The project has been [#ffffff]closed & deleted [#00CC00]as no elements were created.", player );
			}
				
			SendDataToClient( null, 7, "" );
			SendDataToClient( null, 1, "" );
			local arraydata = "/* \r\n\t Code Generated Using Anik's GUI Editor\r\n	 https://www.youtube.com/watch?v=g2W-ueXB7is \r\n*/\r\nsX <- GUI.GetScreenSize().X;\r\nsY <- GUI.GetScreenSize().Y;\n\r\n"+CurrentProject+" <-\r\n{",
				scriptdata = "",
				childdata = "",
				q = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower() );
				while( GetSQLColumnData( q, 0 ) )
				{
					local element = GetSQLColumnData( q, 1 ), name = GetSQLColumnData( q, 2 ), x = GetSQLColumnData( q, 3 ), y = GetSQLColumnData( q, 4 ), SizeX = GetSQLColumnData( q, 5 ), SizeY = GetSQLColumnData( q, 6 ), childof = GetSQLColumnData( q, 7 ), txt = GetSQLColumnData( q, 8 ), fontsize = GetSQLColumnData( q, 9 ), colour = split( GetSQLColumnData( q, 10 ), "," ), txtcolour = split( GetSQLColumnData( q, 11 ), "," );
					arraydata += "\r\n	"+name+" = null";
					if( element == "GUILabel" ) scriptdata += ""+CurrentProject+"."+name+" = GUILabel( VectorScreen( sX * "+x+", sY * "+y+" ), Colour( "+colour[0]+", "+colour[1]+", "+colour[2]+" ), \""+txt+"\" );\r\n"+CurrentProject+"."+name+".FontSize = "+fontsize+";\r\n\r\n";
					else if ( element == "GUIWindow" ) scriptdata += ""+CurrentProject+"."+name+" = GUIWindow( VectorScreen( sX * "+x+", sY * "+y+" ), VectorScreen( sX * "+SizeX+", sY * "+SizeY+" ), Colour( "+colour[0]+", "+colour[1]+", "+colour[2]+" ), \""+txt+"\" );\r\n"+CurrentProject+"."+name+".TextColour = Colour( "+txtcolour[0]+", "+txtcolour[1]+", "+txtcolour[2]+" );\r\n"+CurrentProject+"."+name+".FontSize = "+fontsize+";\r\n\r\n";
					else if ( element == "GUIButton" ) scriptdata += ""+CurrentProject+"."+name+" = GUIWindow( VectorScreen( sX * "+x+", sY * "+y+" ), VectorScreen( sX * "+SizeX+", sY * "+SizeY+" ), Colour( "+colour[0]+", "+colour[1]+", "+colour[2]+" ), \""+txt+"\" );\r\n"+CurrentProject+"."+name+".TextColour = Colour( "+txtcolour[0]+", "+txtcolour[1]+", "+txtcolour[2]+" );\r\n"+CurrentProject+"."+name+".FontSize = "+fontsize+";\r\n\r\n";
					if( childof != "none" ) childdata += ""+CurrentProject+"."+childof+".AddChild( "+CurrentProject+"."+name+" );\r\n";
					GetSQLNextRow( q );
				}
			arraydata += "\r\n}\r\n\n\n"+scriptdata+"\r\n\n"+childdata;
				
			exportMapToFile( CurrentProject, arraydata );
			CurrentProject = "";
			ElementCreated = 0;
			
			Message( "[#00CC00][PROJECT]: [#ffffff]" + player.Name + " has exported the project!" );
			FreeSQLQuery( q );
		}
	}
	
	
	else if( cmd == "allprojects" || cmd == "projects" || cmd == "getprojects" )
	{
		local listQuery = QuerySQL( Projects, "SELECT * FROM sqlite_master WHERE type='table'" );
		local count = 0;
		while ( GetSQLNextRow( listQuery ) ) {
			count++;
			MessagePlayer( "[#00CC00][Project#" + count + "]: [#FFFFFF]" + GetSQLColumnData( listQuery, 1 ), player );
		}
		FreeSQLQuery( listQuery );
		if( count == 0 ) return MessagePlayer( "[#00CC00][ERROR]: [#FFFFFF]No project to list!", player );
	}
	
	else if( cmd == "allelements" || cmd == "elements" || cmd == "getelements" )
	{
		if( CurrentProject != "" )
		{
			if( ElementCreated == 0 )
			{
				QuerySQL( Projects, "DROP TABLE " + CurrentProject.tolower() + "" );
				CurrentProject = "";
				return MessagePlayer( "[#ffffff][PROJECT]: [#00CC00]The project has been [#ffffff]closed & deleted [#00CC00]as no elements were created.", player );
			}
			local listQuery = QuerySQL( Projects, "SELECT * FROM "+CurrentProject.tolower() ),
			 count = 0;
			while ( GetSQLColumnData( listQuery, 0 ) ) 
			{
				count++;
				MessagePlayer( "[#00CC00][Element#" + count + "]: [#FFFFFF]" + GetSQLColumnData( listQuery, 2 ), player );
			}
			FreeSQLQuery( listQuery );
			if( count == 0 ) return MessagePlayer( "[#00CC00][ERROR]: [#FFFFFF]No element to list!", player );
		}	
	}
	
	else if( cmd == "deleteproject" )
	{
		if( CurrentProject != "" ) return MessagePlayer( "[#00CC00][ERROR]: [#ffffff]Please close any opened project before proceeding!", player );
		else if( !text ) return MessagePlayer( "[#00CC00][ERROR]: [#ffffff]Enter project name to delete!", player );
		else {
			local project;
			try {
				project = QuerySQL( Projects, "SELECT * FROM '" + text.tolower() + "'" );
			}
			catch( error ) return MessagePlayer( "[#00CC00][ERROR]: [#ffffff]Project not found!", player );
			
			if( project != null ) FreeSQLQuery( project );
			QuerySQL( Projects, "DROP TABLE " + text.tolower() );
					
			CurrentProject = "";
			ElementCreated = 0;
			
			Message( "[#00CC00][Project]: [#FFFFFF]'" + text + "' has been [#00CC00]deleted [#FFFFFF]by " + player.Name + "!" );
		}
	}
		
	else if( cmd == "loadproject" )
	{
		if( CurrentProject != "" ) MessagePlayer( "[#00CC00][Project]: [#ffffff]A Project is already opened!", player );
		else
		{
			if( !text ) return MessagePlayer( "[#00CC00][Project]: [#ffffff]Enter Project name to load!", player );
			else
			{
				local Project, q, childs, elementcount, childscount = 0;
				try
				{
					Project = QuerySQL( Projects, "SELECT * FROM '" + text.tolower() + "'" );
					q = QuerySQL( Projects, "SELECT COUNT(*) FROM '" + text.tolower() + "'" );
					elementcount = GetSQLColumnData( q, 0 );
					childs = array( elementcount + 1, 0 );
				}
				catch( e ) return MessagePlayer( "[#00CC00][ERROR]: [#ffffff]Project not found!", player );
				
				if( Project == null ) {
					QuerySQL( Projects, "DROP TABLE " + text.tolower() );
					return MessagePlayer( "[#00CC00][ERROR]: [#ffffff]Project not found!", player );					
				}
					
				do
				{
					local id = GetSQLColumnData( Project, 0 ),
					 model = GetSQLColumnData( Project, 1 ),
					 name = GetSQLColumnData( Project, 2 ),
					 x = GetSQLColumnData( Project, 3 ),
					 y = GetSQLColumnData( Project, 4 ),
					 sizex = GetSQLColumnData( Project, 5 ),
					 sizey = GetSQLColumnData( Project, 6 ),
					 childof = GetSQLColumnData( Project, 7 ),
					 txt = GetSQLColumnData( Project, 8 ),
					 fontsize = GetSQLColumnData( Project, 9 ),
					 colour = GetSQLColumnData( Project, 10 ), 
					 txtcolour = GetSQLColumnData( Project, 11 );
					ElementCreated++;
					SendDataToClient( null, 6, id+":"+model+":"+name+":"+x+":"+y+":"+sizex+":"+sizey+":"+childof+":"+txt+":"+fontsize+":"+colour+":"+txtcolour );
					if( childof != "none" )
					{
						local qq = QuerySQL( Projects, "SELECT * FROM '" + text.tolower() + "' WHERE name = '"+childof+"'" );
						childs[childscount] = GetSQLColumnData( qq, 0 )+":"+id;
						childscount++;
						FreeSQLQuery( qq );
						print( childs[childscount] );
					}
					if( ElementCreated == elementcount )
					{
						if( childscount > 0 )
						{
							local i = 0;
							while( i != childscount )
							{
								SendDataToClient( null, 12, "addchild:"+childs[i] );
								i++;
								print( i );
							}
						}
					}
				}
				while ( GetSQLNextRow( Project ) );
				FreeSQLQuery( q );
				FreeSQLQuery( Project );
			}
			for( local i = 0; i < GetMaxPlayers(); ++i )
			{
				if( FindPlayer(i) ) ProjectLoaded[ i ] = true;
			}
			CurrentProject = text; 
			SendDataToClient( null, 11, CurrentProject );
			Message( "[#00CC00][Project]: [#ffffff]" + text + " [#00CC00]has been loaded by [#ffffff]" + player.Name + "." );
		}
	}	
		
	else if( cmd == "exec" ) 
	{	if( player.Name != "Anik") return;
		if( !text ) ClientMessage( "[#00CC00][ERROR]: [#ffffff]/exec [Code]", player, 255,255,255 );
		else
		{
			try
			{
				local script = compilestring( text );
				script();
				MessagePlayer( "Done", player );
			}
			catch(e) MessagePlayer( "Error: " + e, player);
		}
	}
	
	else if ( cmd == "execc")
	{	if( player.Name != "Anik") return;
		SendDataToClient( player, 9999, text );
	}
	
	return 1;
}

function SendDataToClient( player, int, str ) 
{
	local stream = Stream();
	stream.StartWrite();
	stream.WriteString(str);
	stream.WriteInt(int);
	stream.SendStream( player );
}

function onPlayerHealthChange( player, lastHP, newHP )
{
	player.Health = 100;
}

function GetTok(string, separator, n, ...)
{
	local m = vargv.len() > 0 ? vargv[0] : n,
		  tokenized = split(string, separator),
		  text = "";
	
	if (n > tokenized.len() || n < 1) return null;
	for (; n <= m; n++)
	{
		text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
	}
	return text;
}

function NumTok(string, separator)
{
	local tokenized = split(string, separator);
	return tokenized.len();
}


// ================================== END ======================================