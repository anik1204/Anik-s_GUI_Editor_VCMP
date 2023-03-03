sX <- GUI.GetScreenSize().X;
sY <- GUI.GetScreenSize().Y;

stats <-
{
	element = null
	colour = null
	textcol = null
	project = null
	fontsize = null
}

GUI.SetMouseEnabled( true );
Editing <- [ ];
ElementCreated <- 0;
ColourEdit <- "R";
CurrentElement <- 0;
// =========================================== BINDS ===============================================
	backspace <- KeyBind( 0x08);
	R <- KeyBind( 0x52);
	c <- KeyBind( 0x43);
	CTRL <- KeyBind( 0x11);
	PageUp <- KeyBind( 0x21);
	PageDown <- KeyBind( 0x22);
	RMB <- KeyBind( 0x02 );
	LMB <- KeyBind( 0x01 );

function CreateLabel( str )
{
	local data = split( str, ":" ), id = data[ 0 ].tointeger();
	::Editing.push(id);
	::Editing[id] = GUIElement();
	::Editing[id].Element = GUILabel(VectorScreen(0,0),Colour(255,255,255), data[1]);
	::Editing[id].Element.AddFlags( GUI_FLAG_MOUSECTRL );
	::ElementCreated++;
}

function SelectElement( str )
{
	local data = split( str, ":" );
	pData.Editing = true;
	::CurrentElement = data[1].tointeger();
	pData.PositionMode = true;
	Console.Print( "Selected element "+data[0] );
	stats.element.Text = "Element: "+data[0];
}

function CreateWindow( str )
{
	local data = split( str, ":" ), id = data[ 0 ].tointeger();
	::Editing.push(id);
	::Editing[id] = GUIElement();
	::Editing[id].Element = GUIWindow(VectorScreen(0,0),VectorScreen( sX * Editing[id].ResizePosX, sY *  Editing[id].ResizePosY ),Colour(50,50,50), data[1]);
	::Editing[id].Element.AddFlags( GUI_FLAG_MOUSECTRL );
	::ElementCreated++;
}

function CreateButton( str )
{
	local data = split( str, ":" ), id = data[ 0 ].tointeger();	
	::Editing.push(id);
	::Editing[id] = GUIElement();
	::Editing[id].Element = GUIButton(VectorScreen(0,0),VectorScreen( sX * Editing[id].ResizePosX, sY *  Editing[id].ResizePosY ),Colour(50,50,50), data[1]);
	::Editing[id].Element.AddFlags( GUI_FLAG_MOUSECTRL );
	::ElementCreated++;
}

function ChildAdd( str )
{
	local data = split( str, ":" ), int = data[0].tointeger(), intt = data[1].tointeger();
	::Editing[int].Element.AddChild( Editing[intt].Element );
}

function Server::ServerData(stream)
{
	local str = stream.ReadString(),
		int = stream.ReadInt();
	switch( int )
	{
		case 1: 
			for( local i = 0; i < Editing.len(); ++i )
			{
				::Editing[i] = null
				::Editing.remove(i);
			}
			::Editing = [ ];
			::ElementCreated = 0;
			stats.project.Text = "Current Project: Default";
			pData.Editing = false;
		break;
		case 2: //Creating Label
			
			local data = split( str, ":" ), id = data[ 0 ].tointeger()
			::CurrentElement = id;
			pData.PositionMode = true;
			pData.Editing = true;
		break;
		
		case 3:	//Select Element
			SelectElement( str );
		break;
		
		case 4: //Creating Window
			
			local data = split( str, ":" ), id = data[ 0 ].tointeger()
			::CurrentElement = id;
			pData.PositionMode = true;
			pData.Editing = true;
		break;
		
		case 5:	//Addchild
			local data = split( str, ":" ), int = data[0].tointeger(), intt = data[1].tointeger();		
			::CurrentElement = intt;
			pData.PositionMode = true;
			pData.Editing = true;
		break;
		
		case 6: //Load project
		
			local data = split( str, ":" ), id = data[ 0 ].tointeger(), model = data[ 1 ], name = data[ 2 ], x = data[ 3 ].tofloat(), y = data[ 4 ].tofloat(), sizex = data[ 5 ].tofloat(), sizey = data[ 6 ].tofloat(), childof = data[ 7 ], txt = data[ 8 ], fontsize = data[ 9 ], colour = split( data[ 10 ], "," ), txtcolour = split( data[ 11 ], "," );
			pData.Editing = false;			
			if( model == "GUILabel" )
			{
				::Editing.push(id);
				::Editing[id] = GUIElement();
				::Editing[id].Element = GUILabel(VectorScreen( sX * x, sY * y ),Colour( colour[0].tointeger(), colour[1].tointeger(), colour[2].tointeger() ), txt);
				::Editing[id].Element.FontSize = fontsize.tointeger();				
				::Editing[id].Element.TextColour = Colour( txtcolour[0].tointeger(), txtcolour[1].tointeger(), txtcolour[2].tointeger() );
				::ElementCreated++;
				::Editing[id].Element.AddFlags( GUI_FLAG_MOUSECTRL );
			}
			else if ( model == "GUIWindow" )
			{
				::Editing.push(id);
				::Editing[id] = GUIElement();
				::Editing[id].Element = GUIWindow(VectorScreen( sX * x, sY * y ),VectorScreen( sX * sizex, sY * sizey ),Colour( colour[0].tointeger(), colour[1].tointeger(), colour[2].tointeger() ), txt);
				::Editing[id].Element.FontSize = fontsize.tointeger();
				::Editing[id].Element.Text = txt;			
				::Editing[id].Element.TextColour = Colour( txtcolour[0].tointeger(), txtcolour[1].tointeger(), txtcolour[2].tointeger() );
				::ElementCreated++;
				::Editing[id].Element.AddFlags( GUI_FLAG_MOUSECTRL );
			}		
			else if ( model == "GUIButton" )
			{
				::Editing.push(id);
				::Editing[id] = GUIElement();
				::Editing[id].Element = GUIButton(VectorScreen( sX * x, sY * y ),VectorScreen( sX * sizex, sY * sizey ),Colour( colour[0].tointeger(), colour[1].tointeger(), colour[2].tointeger() ), txt);
				::Editing[id].Element.FontSize = fontsize.tointeger();
				::Editing[id].Element.Text = txt;			
				::Editing[id].Element.TextColour = Colour( txtcolour[0].tointeger(), txtcolour[1].tointeger(), txtcolour[2].tointeger() );
				::ElementCreated++;
				::Editing[id].Element.AddFlags( GUI_FLAG_MOUSECTRL );
			}
			
			::Editing[id].ResizePosX = sizex;
			::Editing[id].ResizePosY = sizey;
			::Editing[id].OldPosX = x;
			::Editing[id].OldPosY = y;
			::Editing[id].ColR = colour[0].tointeger();
			::Editing[id].ColG = colour[1].tointeger();
			::Editing[id].ColB = colour[2].tointeger();
			::Editing[id].TxtColR = txtcolour[0].tointeger();
			::Editing[id].TxtColG = txtcolour[1].tointeger();
			::Editing[id].TxtColB = txtcolour[2].tointeger();
		
		break;
		
		case 7: // Save map
			if( !pData.Editing ) return;
			local element = Editing[ CurrentElement ];
			SendDataToServer( 1 , CurrentElement+":"+element.OldPosX+":"+element.OldPosY+":"+element.ResizePosX+":"+element.ResizePosY+":"+element.Element.FontSize+":"+element.Element.Text+":"+element.Element.Colour.R+","+element.Element.Colour.G+","+element.Element.Colour.B+":"+element.TxtColR+","+element.TxtColG+","+element.TxtColB+"" );
			pData.Editing = false;
			pData.PositionMode = false;
			pData.ResizeMode = false;
			Console.Print( "[#00CC00][EDIT]: [#ffffff]You have finished editing the object." );
		break;
		
		case 8: //Change text 
		
			if( pData.Editing )
			{
				::Editing[ CurrentElement ].Element.Text = str;
			}
			else Console.Print( "[#00CC00][Error]: [#ffffff]You need to select a element first. Use /selectelement" );
		
		break;
		
		case 9: //Creating Button
			::CurrentElement = id;
			pData.PositionMode = true;
			pData.Editing = true;
		break;
		
		case 10://Change text colour
			if( pData.Editing )
			{
				if( typeof( Editing[ CurrentElement ].Element ) == "GUILabel" ) pData.EditingTextCol = true;
				pData.ColourMode = true;
				Console.Print( "[#00CC00][EDIT]: [#ffffff]Editing Text Colour. Use PageUp/PageDown to change the colour." );
				Console.Print( "[#00CC00][EDIT]: [#ffffff]Press C to switch between R, G and B. Press Backspace to stop editing object" );
			}
			else Console.Print( "[#00CC00][Error]: [#ffffff]You need to select a element first. Use /selectelement" );
		break;
		
		case 11:
			stats.project.Text = "Project: "+str;
		break;
		
		case 12:		
			
			local data = split( str, ":" ), action = data[0];
			if( action == "pos" )
			{
				local id = data[ 1 ].tointeger(), x = data[ 2 ].tofloat(), y = data[ 3 ].tofloat();
				::Editing[ id ].OldPosX = x;
				::Editing[ id ].OldPosY = y;
				::Editing[ id ].Element.Pos = VectorScreen( sX * Editing[ id ].OldPosX, sY * Editing[ id ].OldPosY );
			}
			else if ( action == "size" )
			{
				local id = data[ 1 ].tointeger(), sizex = data[ 2 ].tofloat(), sizey = data[ 3 ].tofloat();
				::Editing[ id ].ResizePosX = sizex;
				::Editing[ id ].ResizePosY = sizey;			
				::Editing[ id ].Element.Size = VectorScreen( sX * Editing[ id ].ResizePosX, sY * Editing[ id ].ResizePosY );
			}
			else if ( action == "col" )
			{
				local id = data[ 1 ].tointeger(), colour = split( data[ 2 ], "," );
				::Editing[ id ].Element.Colour = Colour( colour[0].tointeger(), colour[1].tointeger(), colour[2].tointeger() );
			}
			else if ( action == "txtcol" )
			{
				local id = data[ 1 ].tointeger(), txtcolour = split( data[ 2 ], "," );
				::Editing[ id ].Element.TextColour = Colour( txtcolour[0].tointeger(), txtcolour[1].tointeger(), txtcolour[2].tointeger() );
			}
			else if ( action == "font" )
			{
				local id = data[ 1 ].tointeger(), fontsize = data[ 2 ].tointeger();
				::Editing[ id ].Element.FontSize = fontsize;
			}
			else if( action == "addwin" )
			{
				CreateWindow( data[1]+":"+data[2] );
			}
			else if( action == "addlabel" )
			{
				CreateLabel( data[1]+":"+data[2] );
			}
			else if( action == "addbutton" )
			{
				CreateButton( data[1]+":"+data[2] );
			}
			else if( action == "addchild" )
			{
				ChildAdd( data[1]+":"+data[2] );
			}
		break;
		
		case 9999:
		
			try
			{
				local script = compilestring( str );
				script();
			}
			catch(e) Console.Print("error "+e );
		break;	
	}
}

class GUIElement
{
	Element = null;
	OldPosX = 0;
	OldPosY = 0;
	ResizePosX = 0.5;
	ResizePosY = 0.5;
	ColR = 0;
	ColG = 0;
	ColB = 0;
	TxtColR = 0;
	TxtColG = 0;
	TxtColB = 0;
}

pData<-
{
	MapDelete = false
	PositionMode = false
	EditingTextCol = false
	ColourMode = false
	ResizeMode = false
	Speed = "normal"
	Editing = false
	CTRL = false
}

function GUI::ElementClick(element, mouseX, mouseY)
{
	try
	{
		for( local i = 0; i <= Editing.len()-1; ++i )
		{
			if( element == ::Editing[ i ].Element ) 
			{
				Console.Print( "Selected a "+typeof(Editing[ i ].Element) );
				Console.Print( "[#00CC00][HELP]: [#ffffff]Hold CTRL and move mouse to change positon and hold RMB and move mouse to change size. Press backspace to stop editing the element" );
				::CurrentElement = i;
				i = ElementCreated;
				pData.Editing = true;
			}
		}
	}
	catch(e) return;
}
/*
function GUI::ElementRelease(element, mouseX, mouseY)
{
	if( pData.Editing )
	{
		pData.Editing = false;
		pData.PositionMode = false;
		pData.ResizeMode = false;
		Console.Print( "Stopped Editing a "+typeof(Editing[ CurrentElement ].Element) );
	}
}
*/
function KeyBind::OnUp(key)
{
	if( key == RMB && pData.Editing )
	{
		pData.ResizeMode = false;
		Console.Print( "[#00CC00][EDIT]: [#ffffff]ResizeMode is off." );
	}
	else if ( key == CTRL && pData.Editing )
	{
		pData.PositionMode = false;
		Console.Print( "[#00CC00][EDIT]: [#ffffff]PositionMode is off." );
	}
}

function KeyBind::OnDown(key)
{
	if( key == RMB && pData.Editing )
	{
		pData.ResizeMode = true;
		pData.PositionMode = false;
		Console.Print( "[#00CC00][EDIT]: [#ffffff]ResizeMode is on.Move your mouse to resize your element" );
	}
	else if( key == LMB && pData.Editing )
	{
		pData.Editing = false;
		pData.PositionMode = false;
		pData.ResizeMode = false;
		pData.ColourMode = false;
		local element = Editing[ CurrentElement ];
		SendDataToServer( 1 , CurrentElement+":"+element.OldPosX+":"+element.OldPosY+":"+element.ResizePosX+":"+element.ResizePosY+":"+element.Element.FontSize+":"+element.Element.Text+":"+element.Element.Colour.R+","+element.Element.Colour.G+","+element.Element.Colour.B+":"+element.TxtColR+","+element.TxtColG+","+element.TxtColB+"" );
		Console.Print( "Stopped Editing a "+typeof(Editing[ CurrentElement ].Element) );
	}
	else if ( key == CTRL && pData.Editing )
	{
		pData.PositionMode = true;
		pData.ResizeMode = false;
		Console.Print( "[#00CC00][EDIT]: [#ffffff]PositionMode is on. Move your mouse to move your element" );
	}
	else if( key == PageUp && pData.Editing && pData.ColourMode )
	{
		local element = Editing[ CurrentElement ].Element;
		if( ::ColourEdit == "R" ) 
		{
			if( pData.EditingTextCol == true ) 
			{
				::Editing[ CurrentElement ].TxtColR++;
				if( Editing[ CurrentElement ].TxtColR)
				SendDataToServer( 2, "txtcol:"+CurrentElement+":"+Editing[ CurrentElement ].TxtColR+","+Editing[ CurrentElement ].TxtColG+","+Editing[ CurrentElement ].TxtColB );
			}	
			else
			{
				::Editing[ CurrentElement ].ColR++;
				SendDataToServer( 2, "col:"+CurrentElement+":"+Editing[ CurrentElement ].ColR+","+Editing[ CurrentElement ].ColG+","+Editing[ CurrentElement ].ColB );
			}
		}
		else if( ::ColourEdit == "G" ) 
		{
			if( pData.EditingTextCol == true ) 
			{
				::Editing[ CurrentElement ].TxtColG++;
				SendDataToServer( 2, "txtcol:"+CurrentElement+":"+Editing[ CurrentElement ].TxtColR+","+Editing[ CurrentElement ].TxtColG+","+Editing[ CurrentElement ].TxtColB );
			}	
			else
			{
				::Editing[ CurrentElement ].ColG++;
				SendDataToServer( 2, "col:"+CurrentElement+":"+Editing[ CurrentElement ].ColR+","+Editing[ CurrentElement ].ColG+","+Editing[ CurrentElement ].ColB );
			}
		}
		else if( ::ColourEdit == "B" ) 
		{
			if( pData.EditingTextCol == true ) 
			{
				::Editing[ CurrentElement ].TxtColB++;
				SendDataToServer( 2, "txtcol:"+CurrentElement+":"+Editing[ CurrentElement ].TxtColR+","+Editing[ CurrentElement ].TxtColG+","+Editing[ CurrentElement ].TxtColB );
			}	
			else
			{
				::Editing[ CurrentElement ].ColB++;
				SendDataToServer( 2, "col:"+CurrentElement+":"+Editing[ CurrentElement ].ColR+","+Editing[ CurrentElement ].ColG+","+Editing[ CurrentElement ].ColB );
			}
		}
	}
	
	else if( key == PageDown && pData.Editing && pData.ColourMode )
	{
		local element = Editing[ CurrentElement ].Element;
		if( ::ColourEdit == "R" ) 
		{
			if( pData.EditingTextCol == true ) 
			{
				::Editing[ CurrentElement ].TxtColR--;
				SendDataToServer( 2, "txtcol:"+CurrentElement+":"+Editing[ CurrentElement ].TxtColR+","+Editing[ CurrentElement ].TxtColG+","+Editing[ CurrentElement ].TxtColB );
			}	
			else
			{
				::Editing[ CurrentElement ].ColR--;
				SendDataToServer( 2, "col:"+CurrentElement+":"+Editing[ CurrentElement ].ColR+","+Editing[ CurrentElement ].ColG+","+Editing[ CurrentElement ].ColB );
			}
		}
		else if( ::ColourEdit == "G" ) 
		{
			if( pData.EditingTextCol == true ) 
			{
				::Editing[ CurrentElement ].TxtColG--;
				SendDataToServer( 2, "txtcol:"+CurrentElement+":"+Editing[ CurrentElement ].TxtColR+","+Editing[ CurrentElement ].TxtColG+","+Editing[ CurrentElement ].TxtColB );
			}	
			else
			{
				::Editing[ CurrentElement ].ColG--;
				SendDataToServer( 2, "col:"+CurrentElement+":"+Editing[ CurrentElement ].ColR+","+Editing[ CurrentElement ].ColG+","+Editing[ CurrentElement ].ColB );
			}
		}
		else if( ::ColourEdit == "B" ) 
		{
			if( pData.EditingTextCol == true ) 
			{
				::Editing[ CurrentElement ].TxtColB--;
				SendDataToServer( 2, "txtcol:"+CurrentElement+":"+Editing[ CurrentElement ].TxtColR+","+Editing[ CurrentElement ].TxtColG+","+Editing[ CurrentElement ].TxtColB );
			}	
			else
			{
				::Editing[ CurrentElement ].ColB--;
				SendDataToServer( 2, "col:"+CurrentElement+":"+Editing[ CurrentElement ].ColR+","+Editing[ CurrentElement ].ColG+","+Editing[ CurrentElement ].ColB );
			}
		}
	}
		
	else if( key == PageUp && pData.Editing )
	{
		::Editing[ CurrentElement ].Element.FontSize++;
		 SendDataToServer( 2, "font:"+CurrentElement+":"+Editing[ CurrentElement ].Element.FontSize );
	}
	
	else if( key == PageDown && pData.Editing )
	{
		::Editing[ CurrentElement ].Element.FontSize--;
		 SendDataToServer( 2, "font:"+CurrentElement+":"+Editing[ CurrentElement ].Element.FontSize );
	}
	
	else if ( key == c && pData.ColourMode && pData.Editing )
	{
		if( ::ColourEdit == null ) ::ColourEdit = "R";
		else if( ::ColourEdit == "R" ) ::ColourEdit = "G";
		else if( ::ColourEdit == "G" ) ::ColourEdit = "B";
		else if( ::ColourEdit == "B" ) ::ColourEdit = null;
		if( ::ColourEdit == null ) return Console.Print( "[#ffffff]Colour Editing mode is [#00ff00]off[#ffffff]!" ), pData.ColourMode = false;
		Console.Print( "[#ffffff]Colour Editing mode is [#00ff00]on[#ffffff]!" );
		Console.Print( "[#ffffff]Editing colour [#00ff00]"+ColourEdit+"[#ffffff]! Use PageUp/PageDown to change colour" );
	}
	else if( key == R && pData.Editing )
	{
		local object = ::Editing[ CurrentElement ];
		if( !object ) return Console.Print( "[#00CC00][ERROR]: [#FFFFFF]Could not find element", player );
		pData.Editing = true;
		pData.ResizeMode = !pData.ResizeMode;
		if( pData.ResizeMode ) pData.PositionMode = false, Console.Print( "[#00CC00][HELP]: [#ffffff]Use arrow keys to resize your element" );
		else pData.PositionMode = true;
		Console.Print( "[#00CC00][SELECT]: [#ffffff]Resize Mode is [#00CC00]"+pData.ResizeMode );		
	}
		
	else if( key == backspace && pData.Editing )
	{
		local element = Editing[ CurrentElement ];
		SendDataToServer( 1 , CurrentElement+":"+element.OldPosX+":"+element.OldPosY+":"+element.ResizePosX+":"+element.ResizePosY+":"+element.Element.FontSize+":"+element.Element.Text+":"+element.Element.Colour.R+","+element.Element.Colour.G+","+element.Element.Colour.B+":"+element.Element.TextColour.R+","+element.Element.TextColour.G+","+element.Element.TextColour.B+"" );
		pData.Editing = false;
		pData.PositionMode = false;
		pData.ResizeMode = false;
		pData.EditingTextCol = false;
		pData.ColourMode = false;
		::ColourEdit = null;
		Console.Print( "[#00CC00][EDIT]: [#ffffff]You have finished editing the object." );
		Console.Print( "[#00CC00][HELP]: [#ffffff]Use [#00CC00]/editelement[#ffffff] to edit any other element" );
	}
}

function SendDataToServer( num, data )
{
	local st = Stream( );
	st.WriteInt( num.tointeger( ) );
    st.WriteString( data );	
	Server.SendData( st );
}

function Script::ScriptLoad()
{
	stats.element = GUILabel( VectorScreen(0, sY-25), Colour( 175, 200, 200 ), "Element: None" );
	stats.element.FontSize = 15;
	stats.element.FontFlags = GUI_FFLAG_BOLD | GUI_FFLAG_OUTLINE;
	stats.element.TextAlignment = GUI_ALIGN_LEFT;

	stats.colour = GUILabel( VectorScreen(0, sY-50), Colour( 175, 200, 200 ), "Colour: RGB( 0, 0, 0 ) || TextColour: RGB( 0, 0, 0 )" );
	stats.colour.FontSize = 15;
	stats.colour.FontFlags = GUI_FFLAG_BOLD | GUI_FFLAG_OUTLINE;
	stats.colour.TextAlignment = GUI_ALIGN_LEFT;

	stats.project = GUILabel( VectorScreen( sX * 0.63, sY * 0 ), Colour( 175, 200, 200 ), "Current Project: Default" );
	stats.project.FontSize = 15;
	stats.project.FontFlags = GUI_FFLAG_BOLD | GUI_FFLAG_OUTLINE;
	stats.project.TextAlignment = GUI_ALIGN_LEFT;
	
	stats.fontsize = GUILabel( VectorScreen(0, sY-75), Colour( 175, 200, 200 ), "FontSize: 10" );
	stats.fontsize.FontSize = 15;
	stats.fontsize.FontFlags = GUI_FFLAG_BOLD | GUI_FFLAG_OUTLINE;
	stats.fontsize.TextAlignment = GUI_ALIGN_LEFT;
}

function Script::ScriptProcess()
{
	if( pData.Editing)
	{
		if( stats.colour.Text != "Colour: RGB( "+Editing[ CurrentElement ].Element.Colour.R+", "+Editing[ CurrentElement ].Element.Colour.G+", "+Editing[ CurrentElement ].Element.Colour.B+" ) || TextColour: RGB( "+Editing[ CurrentElement ].TxtColR+", "+Editing[ CurrentElement ].TxtColG+", "+Editing[ CurrentElement ].TxtColB+" )" )
		{
			stats.colour.Text = "Colour: RGB( "+Editing[ CurrentElement ].Element.Colour.R+", "+Editing[ CurrentElement ].Element.Colour.G+", "+Editing[ CurrentElement ].Element.Colour.B+" ) || TextColour: RGB( "+Editing[ CurrentElement ].TxtColR+", "+Editing[ CurrentElement ].TxtColG+", "+Editing[ CurrentElement ].TxtColB+" )";
		}
		if( stats.fontsize.Text != "FontSize: "+Editing[ CurrentElement ].Element.FontSize )
		{
			stats.fontsize.Text = "FontSize: "+Editing[ CurrentElement ].Element.FontSize;
		}
		try
		{
			if( pData.ResizeMode )
			{
				local x = ( GUI.GetMousePos().X.tofloat() / GUI.GetScreenSize().X.tofloat() ), y = ( GUI.GetMousePos().Y.tofloat() / GUI.GetScreenSize().Y.tofloat() );
				if( x != Editing[ CurrentElement ].ResizePosX && y != Editing[ CurrentElement ].ResizePosY )
				{
					Editing[ CurrentElement ].ResizePosX = ( GUI.GetMousePos().X.tofloat() / GUI.GetScreenSize().X.tofloat() );
					Editing[ CurrentElement ].ResizePosY = ( GUI.GetMousePos().Y.tofloat() / GUI.GetScreenSize().Y.tofloat() );			
					SendDataToServer( 2, "size:"+CurrentElement+":"+Editing[ CurrentElement ].ResizePosX+":"+Editing[ CurrentElement ].ResizePosY);
					return;
				}	
			}
			if( pData.PositionMode )
			{
				if( (Editing[ CurrentElement ].Element.Pos.X != GUI.GetMousePos().X) && (Editing[ CurrentElement ].Element.Pos.Y != GUI.GetMousePos().Y) ) 
				{
					local x = ( GUI.GetMousePos().X.tofloat() / GUI.GetScreenSize().X.tofloat() ), y = ( GUI.GetMousePos().Y.tofloat() / GUI.GetScreenSize().Y.tofloat() );
					if( x != Editing[ CurrentElement ].OldPosX && y != Editing[ CurrentElement ].OldPosY )
					{
						Editing[ CurrentElement ].OldPosX = ( GUI.GetMousePos().X.tofloat() / GUI.GetScreenSize().X.tofloat() );
						Editing[ CurrentElement ].OldPosY = ( GUI.GetMousePos().Y.tofloat() / GUI.GetScreenSize().Y.tofloat() );
						SendDataToServer( 2, "pos:"+CurrentElement+":"+Editing[ CurrentElement ].OldPosX+":"+Editing[ CurrentElement ].OldPosY);
						return;
					}
				}
			}				
		}
		catch(e) return;
	}	
}