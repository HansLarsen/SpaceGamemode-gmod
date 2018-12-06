include( "shared.lua" )

print("Starting Client side script")

local TeamSelected2, score, money = 5, 0, 0

net.Receive( "Hax.TeamMenu", function(len, ply)
	local Frame = vgui.Create( "DFrame" )
	Frame:SetTitle( "Team Menu" )
	Frame:SetSize( 300, 125 )
	Frame:Center()
	Frame:MakePopup()
	Frame:DockPadding( 10, 30, 10, 10 )
	
	local pirate = vgui.Create( "DButton", Frame)
	pirate:Dock( TOP )
	pirate:SetText( "The Pirates as a ore specialist" )
	pirate.DoClick = function() 
		sendTeamChange( 2, ply )
		Frame:Close()
	end
	

	local starfleet = vgui.Create( "DButton", Frame)
	starfleet:Dock( TOP )
	starfleet:SetText( "The Pirates as a tiberium fanatic" )
	starfleet.DoClick = function() 
		sendTeamChange( 4, ply )
		Frame:Close()
	end
	

	local tiberium = vgui.Create( "DButton", Frame)
	tiberium:Dock( TOP )
	tiberium:SetText( "The Starfleet as a ore specialist" )
	tiberium.DoClick = function() 
		sendTeamChange( 1, ply )
		Frame:Close()
	end
	

	local ore = vgui.Create( "DButton", Frame)
	ore:Dock( TOP )
	ore:SetText( "The Starfleet as a tiberium fanatic" )
	ore.DoClick = function() 
		sendTeamChange( 3, ply )
		Frame:Close()
	end
	
end )

net.Receive( "Hax.TeamValue", function(len, ply)
	TeamSelected2 = net.ReadInt( 8 )
	score = net.ReadFloat()
	money = net.ReadFloat()
end )

function sendTeamChange( teamSelected, ply )
	TeamSelected2 = teamSelected
	net.Start("Hax.TeamSelect")
	net.WriteType(teamSelected)
	net.WriteEntity(ply)
	net.SendToServer()
end

local scoreFrame
function GM:ScoreboardShow()
	net.Start("Hax.ScoreBoard.GetScore")
	net.SendToServer()
end
net.Receive("Hax.ScoreBoard.RecieveScore", function( len, ply )
	players = net.ReadTable()
	scores = net.ReadTable()

	scoreFrame = vgui.Create( "DFrame" )
	scoreFrame:SetTitle( "Scoreboard" )
	scoreFrame:SetSize( ScrW() * ( 10/12 ), ScrH() * ( 10/12 ) )
	scoreFrame:Center()
	scoreFrame:MakePopup()
	scoreFrame:DockPadding( 10, 30, 10, 10 )
	for k,v in pairs(players) do
		net.Start("Hax.ScoreBoard.GetScore")
		local pirate = vgui.Create( "DButton", scoreFrame)
		pirate:DockPadding( 2, 2, 2, 2 )
		pirate:Dock( TOP )
		pirate:SetSize( ScrW() * ( 7/12 ), ScrH() * ( 1/12 ) )

		local Avatar = vgui.Create( "AvatarImage", pirate )
		Avatar:Dock( LEFT )
		Avatar:SetPlayer( v, 64 )

		pirate:SetText( "Name: " .. v:Nick() .. " -- Score: " .. scores[k] )
		pirate.DoClick = function() 
			v:ShowProfile()
			scoreFrame:Close()
		end
	end
end )

function GM:ScoreboardHide()
	if IsValid(scoreFrame) then
		scoreFrame:Close()
	end
	return
end


local teams = {}
teams[1] = "Starfleet as a Ore specialist"
teams["1"] = Color( 145, 89, 29, 255 )
teams[2] = "Pirate as a Ore specialist"
teams["2"] = Color( 145, 89, 29, 255 )
teams[3] = "StarFleet as a Tiberium fanatic"
teams["3"] = Color( 77, 147, 39, 255 )
teams[4] = "Pirate as a Tiberium fanatic"
teams["4"] = Color( 77, 147, 39, 255 )
teams[5] = "Loading"
teams["5"] = Color( 255, 0, 255, 255 )

function GM:HUDPaint()
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawRect( 0, 0, ScrW(), 35 )
	surface.SetDrawColor( teams[tostring( TeamSelected2 )] )
	surface.DrawLine( 0, 35, ScrW(), 35 )
	draw.SimpleTextOutlined("Standing: " .. teams[ TeamSelected2 ], DermaDefault, 10, ScrH() / 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ))
	draw.SimpleTextOutlined("Score: " .. score, DermaDefault, ScrW() / 3, ScrH() / 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ))
	draw.SimpleTextOutlined("Money: " .. money, DermaDefault, ScrW() * ( 2 / 3 ), ScrH() / 100, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color( 0, 0, 0, 255 ))
end