include( "shared.lua" )

local prices = {}
prices["ore"] = {}
prices["ore"]["Buy Price"] = 0
prices["ore"]["Sell Price"] = 200

prices["ice"] = {}
prices["ice"]["Buy Price"] = 0
prices["ice"]["Sell Price"] = 200

prices["tiberium"] = {}
prices["tiberium"]["Buy Price"] = 0
prices["tiberium"]["Sell Price"] = 250

prices["energy"] = {}
prices["energy"]["Buy Price"] = 1
prices["energy"]["Sell Price"] = 0

prices["water"] = {}
prices["water"]["Buy Price"] = 1
prices["water"]["Sell Price"] = 0

local temp = {}

function Terminal( len, ply )
    local playerTable = {}
    playerTable = net.ReadTable()
    --PrintTable(playerTable)

    local Frame = vgui.Create( "DFrame" )
    Frame:SetPos( ScrW() * (1/45), ScrH() * (1/45) )
    Frame:SetSize( ScrW() * (8/10), ScrH() * (8/10) )
    Frame:SetTitle( "Terminal" )
    Frame:SetVisible( true )
    Frame:SetDraggable( true )
    Frame:ShowCloseButton( true )
    Frame:MakePopup()

    local underframe = vgui.Create( "DPanel", Frame )
	underframe:Dock( TOP )
    underframe:SetSize( ScrW() * (2/10), ScrH() * (1/30) )

    for k,v in pairs(playerTable["playerData"]) do
        local DLabel = vgui.Create( "DLabel", underframe )
        DLabel:Dock( LEFT )
        DLabel:SetColor(Color(0,0,0))
        DLabel:SetText( k .. ": " .. v )
        if k == "Score" then
            DLabel:DockMargin( 10, 0, 0, 0 )
        else
            DLabel:DockMargin( 50, 0, 0, 0 )
        end
    end

    local underframe3 = vgui.Create( "DPanel", Frame )
	underframe3:Dock( TOP )
    underframe3:SetSize( ScrW() * (2/10), ScrH() * (1/30) )
    underframe3:DockMargin( 0, 5, 0, 0 )

    for k,v in pairs( {"Name", "Amount"} ) do
        local DLabel2 = vgui.Create( "DLabel", underframe3 )
	    DLabel2:Dock( LEFT )
        DLabel2:SetColor(Color(0,0,0))
        DLabel2:SetText( v )
        if v == "Name" then
            DLabel2:DockMargin( 10, 0, 0, 0 )
        else
            DLabel2:DockMargin( 50, 0, 0, 0 )
        end
    end

    for k,v in pairs( {"Amount", "Sell / Buy"} ) do
        local DLabel2 = vgui.Create( "DLabel", underframe3 )
	    DLabel2:Dock( LEFT )
        DLabel2:SetColor(Color(0,0,0))
        DLabel2:SetText( v )
        if v == "Amount" then
            DLabel2:DockMargin( 200, 0, 0, 0 )
        else
            DLabel2:DockMargin( 60, 0, 0, 0 )
        end
    end

    for k,v in pairs( {"Buy Price", "Sell Price"} ) do
        local DLabel = vgui.Create( "DLabel", underframe3 )
	    DLabel:Dock( RIGHT )
        DLabel:SetColor(Color(0,0,0))
        DLabel:SetText( v )
        if k == "Buy Price" then
            DLabel:DockMargin( 10, 0, 0, 0 )
        else
            DLabel:DockMargin( 25, 0, 0, 0 )
        end
    end

    for k,v in pairs(playerTable["resources"]) do  

        if prices[k] == nil then
            continue
        end

        local underframe2 = vgui.Create( "DPanel", Frame )
	    underframe2:Dock( TOP )
        underframe2:SetSize( ScrW() * (2/10), ScrH() * (1/30) )
        underframe2:DockMargin( 0, 5, 0, 0 )

        local DLabel = vgui.Create( "DLabel", underframe2 )
	    DLabel:Dock( LEFT )
        DLabel:SetColor(Color(0,0,0))
        DLabel:SetText( k )
        DLabel:DockMargin( 10, 0, 0, 0 )

        local DLabel4 = vgui.Create( "DLabel", underframe2 )
	    DLabel4:Dock( LEFT )
        DLabel4:SetColor(Color(0,0,0))
        DLabel4:SetText( v["value"] )
        DLabel4:DockMargin( 50, 0, 0, 0 )

        local TextEntry = vgui.Create( "DTextEntry", underframe2 ) -- create the form as a child of frame
        TextEntry:Dock( LEFT )
        TextEntry:SetSize( ScrW() * (1/20), ScrH() * (1/50) )
        TextEntry:DockMargin( 190, 0, 0, 0 )
        TextEntry.OnEnter = function( obj )
            local temps = tonumber(obj:GetValue())
            --print(temps)
            if isnumber( temps ) then 
	            temp[k] = temps
            end
        end

        local DermaButton = vgui.Create( "DButton", underframe2 ) // Create the button and parent it to the frame
        DermaButton:SetText( "Sell" )					// Set the text on the button
        DermaButton:Dock( LEFT )
        DermaButton:DockMargin( 20, 0, 0, 0 )
        DermaButton.DoClick = function()				// A custom function run when clicked ( note the . instead of : )
            if temp[k] == nil then
                return
            end
	        net.Start("Hax.Terminal.Sell")
	        net.WriteString(k)
            net.WriteFloat( temp[k] )
            net.WriteInt( prices[k]["Sell Price"], 10)
	        net.SendToServer()

            temp[k] = nil
        end

        local DermaButton2 = vgui.Create( "DButton", underframe2 ) // Create the button and parent it to the frame
        DermaButton2:SetText( "Buy" )					// Set the text on the button
        DermaButton2:Dock( LEFT )
        DermaButton2:DockMargin( 2, 0, 0, 0 )
        DermaButton2.DoClick = function()				// A custom function run when clicked ( note the . instead of : )
            if temp[k] == nil then
                return
            end
	        net.Start("Hax.Terminal.Buy")
	        net.WriteString(k)
            net.WriteFloat( temp[k] )
            net.WriteInt( prices[k]["Buy Price"], 10)
	        net.SendToServer()

            temp[k] = nil
        end

        local DLabel2 = vgui.Create( "DLabel", underframe2 )
	    DLabel2:Dock( RIGHT )
        DLabel2:SetColor(Color(0,0,0))
        DLabel2:SetText( prices[k]["Buy Price"] )
        DLabel2:DockMargin( 10, 0, 0, 0 )

        local DLabel3 = vgui.Create( "DLabel", underframe2 )
	    DLabel3:Dock( RIGHT )
        DLabel3:SetColor(Color(0,0,0))
        DLabel3:SetText( prices[k]["Sell Price"] )
        DLabel3:DockMargin( 25, 0, 0, 0 )
    end
end

net.Receive("Hax.Terminal", Terminal )