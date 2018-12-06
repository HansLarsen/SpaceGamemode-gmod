include( "shared.lua" )

local UPrices = {}

UPrices["Ore Lasers"] = 200
UPrices["Tiberium Drills"] = 200
UPrices["Ice Lasers"] = 200
UPrices["Refiner Level"] = 200

local Frame

net.Receive("Hax.Terminal.Upgrades", function( len, ply )
    if IsValid(Frame) then 
        Frame:Close()
    end
    local Upgrade = net.ReadTable()
    Frame = vgui.Create( "DFrame" )
    Frame:SetPos( (ScrW() * (1/2)) - (ScrW() * (5/20)), ScrH() * (1/10) )
    Frame:SetSize( ScrW() * (5/10) , ScrH() * (2.4/10) )
    Frame:SetTitle( "Upgrade Terminal" )
    Frame:SetVisible( true )
    Frame:SetDraggable( true )
    Frame:ShowCloseButton( true )
    Frame:MakePopup()

    local underframe3 = vgui.Create( "DPanel", Frame )
	underframe3:Dock( TOP )
    underframe3:SetSize( ScrW() * (2/10), ScrH() * (1/30) )
    underframe3:DockMargin( 0, 5, 0, 0 )

    for k,v in pairs( {"Name", "Up Cost"} ) do
        local DLabel2 = vgui.Create( "DLabel", underframe3 )
        DLabel2:SetColor(Color(0,0,0))
        DLabel2:SetText( v )
        if v == "Name" then
            DLabel2:Dock( LEFT )
            DLabel2:DockMargin( 50, 0, 0, 0 )
        else
        	DLabel2:Dock( RIGHT )
            DLabel2:DockMargin( 0, 0, 150, 0 )
        end
    end

    for k,v in pairs(UPrices) do
        local underframe = vgui.Create( "DPanel", Frame )
        underframe:Dock( TOP )
        underframe:SetSize( ScrW() * (2/10), ScrH() * (1/30) )
        underframe:DockMargin( 0, 5, 0, 0 )

        local DLabel4 = vgui.Create( "DLabel", underframe )
	    DLabel4:Dock( LEFT )
        DLabel4:SetColor(Color(0,0,0))
        DLabel4:SetText( k )
        DLabel4:DockMargin( 50, 0, 0, 0 )

        local DermaButton = vgui.Create( "DButton", underframe ) // Create the button and parent it to the frame
        DermaButton:SetText( "Buy" )					// Set the text on the button
        DermaButton:Dock( RIGHT )
        DermaButton:DockMargin( 0, 0, 50, 0 )
        DermaButton.DoClick = function() 
            net.Start("Hax.Terminal.Upgrades.Buy")
            net.WriteString(k)
            net.SendToServer()
        end				// A custom function run when clicked ( note the . instead of : )

        --PrintTable(Upgrade)

        local DLabel5 = vgui.Create( "DLabel", underframe )
	    DLabel5:Dock( RIGHT )
        DLabel5:SetColor(Color(0,0,0))
        DLabel5:SetText((Upgrade[k]+1)*v)
        DLabel5:DockMargin( 0, 0, 20, 0 )

        local DLabel6 = vgui.Create( "DLabel", underframe )
	    DLabel6:Dock( RIGHT )
        DLabel6:SetColor(Color(0,0,0))
        DLabel6:SetText("Tier " .. math.floor(Upgrade[k] / 10) .. "." .. string.sub(Upgrade[k],string.len(Upgrade[k])-1,string.len(Upgrade[k])))
        DLabel6:DockMargin( 0, 0, 20, 0 )
    end
end )