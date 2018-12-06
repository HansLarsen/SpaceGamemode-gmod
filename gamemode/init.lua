AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

require( "mysqloo" )

include("shared.lua")
include("mapspawn.lua")

util.AddNetworkString( "Hax.TeamMenu" )
util.AddNetworkString( "Hax.TeamSelect" )
util.AddNetworkString( "Hax.TeamValue" )
util.AddNetworkString( "Hax.NPCUsed" )
util.AddNetworkString( "Hax.Terminal" )
util.AddNetworkString( "Hax.Terminal.Upgrades" )
util.AddNetworkString( "Hax.Terminal.Upgrades.Update" )
util.AddNetworkString( "Hax.Terminal.Upgrades.Buy" )
util.AddNetworkString( "Hax.Terminal.Upgrades.Sell" )
util.AddNetworkString( "Hax.Terminal.Buy" )
util.AddNetworkString( "Hax.Terminal.Sell" )
util.AddNetworkString( "Hax.ScoreBoard.GetScore" )
util.AddNetworkString( "Hax.ScoreBoard.RecieveScore" )

miningLaserTable = {}
miningLaserIsOn = {}
UpgradeTable = {}
miningLaserUpdateRemover = "Hax.MiningLaserTimerRemover"

local Starfleet_Ore, Pirate_Ore, StarFleet_Tiberium, Pirate_Tiberium = 1, 2, 3, 4
local plyTeam = 0

db = mysqloo.connect( "localhost", "gmod", "Cake4242", "garrysmod", 3306 )
db:connect()

function db:onConnected()

    print( "Database has connected!" )

end

function db:onConnectionFailed( err )

    print( "Connection to database failed!" )
    print( "Error:", err )

end

function miningLaserUpdateRemover2()
	--print( "Table Cleanup" )
	--PrintTable(miningLaserTable)
	for k,v in pairs( miningLaserTable ) do
		--PrintTable(v)
		for l,b in pairs( v ) do
			if !IsValid(b) then
				table.remove(miningLaserTable[k], l)
			end
		end
	end
	for k,v in pairs( AsteroidStorage ) do
		--PrintTable(v)
		if !IsValid(v) then
			table.remove(AsteroidStorage, k)
		end
	end
end

timer.Create( miningLaserUpdateRemover, 60, 0, miningLaserUpdateRemover2 )
timer.Start( miningLaserUpdateRemover )

function PlySetTeam( Faction, ply )
	ply:SetTeam( Faction )
	if Faction == Starfleet_Ore then
		--Starfleet_Ore
		local r = math.Round( math.Rand( 1, 2 ), 0 )
		--ply:ChatPrint( r .. ply:Name() )
		if r == 1 then
			ply:SetModel( "models/player/breen.mdl" )
		elseif r == 2 then
			ply:SetModel( "models/player/mossman.mdl" )
		end
	elseif Faction == Pirate_Ore then
		--Pirate_Ore
		local r = math.Round( math.Rand( 1, 2 ), 0 )
		--ply:ChatPrint( r .. ply:Name() )
		if r == 1 then
			ply:SetModel( "models/player/Kleiner.mdl" )
		elseif r == 2 then
			ply:SetModel( "models/player/gman_high.mdl" )
		end
	elseif Faction == StarFleet_Tiberium then
		--StarFleet_Tiberium
		ply:SetModel( "models/player/Barney.mdl" )
	else
		--Pirate_Tiberiums
		ply:SetModel( "models/player/odessa.mdl" )
	end
end

function initDatabase( ply, steamid, nick )
	local Query = db:query("SELECT * FROM users WHERE steamid='" .. steamid .. "'")
	function Query:onSuccess( q, data )
		--PrintTable ( q )
		if table.Count( q ) == 0 then 
			local preparedQuery = db:prepare("INSERT INTO users (`steamid`, `name`, `rank`, `playtime`, `team`, `score`, `money`, `tiberiumPercent`, `orePercent`, `icePercent`) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")
			function preparedQuery:onSuccess(data)
				print("Database Entry for " .. nick .. " created successfully")
			end
			function preparedQuery:onError(err)
				print("An error occured while add user entry: " .. err)
			end
			preparedQuery:setString(1, steamid )
			preparedQuery:setString(2, nick ) -- you don't need to escape the string if you use setString
			preparedQuery:setNull(3)
			preparedQuery:setNumber(4, 100)
			preparedQuery:setNumber(5, ply:Team() )
			preparedQuery:setNumber(6, 0 )
			preparedQuery:setNumber(7, 0 )
			preparedQuery:setNumber(8, 0 )
			preparedQuery:setNumber(9, 0 )
			preparedQuery:setNumber(10, 0 )
			preparedQuery:start()
			ply:SetPData("Hax.SpacePirates.Score",0)
			ply:SetPData("Hax.SpacePirates.Money",100)
			print(nick .. " Created successfully as team " .. ply:Team() )

			net.Start( "Hax.TeamValue")
			net.WriteInt( ply:Team(), 8 )
			net.WriteFloat( 0 )
			net.WriteFloat( 0 )
			net.Send( ply )
		else
			--PrintTable( q )
			if q[1]["name"] != nick then -- the player is always in index 1 because we do WHERE with the steamid--
				local nameChange = db:prepare("UPDATE users SET name='"..nick.."' WHERE steamid='"..steamid.."';")
				nameChange:start()
				function nameChange:onSuccess(data)
					print("name for " .. nick .. " updated successfully")
				end
			end
			ply:SetTeam( q[1]["team"] )
			ply:SetPData("Hax.SpacePirates.Score",q[1]["score"])
			ply:SetPData("Hax.SpacePirates.Money",q[1]["money"])
			ply:SetPData("Hax.SpacePirates.tiberiumPercent",q[1]["tiberiumPercent"])
			ply:SetPData("Hax.SpacePirates.orePercent",q[1]["orePercent"])
			ply:SetPData("Hax.SpacePirates.icePercent",q[1]["icePercent"])

			if q[1]["tiberiumLevel"] != nil then
				UpgradeTable[ply:SteamID()]["Tiberium Drills"] = q[1]["tiberiumLevel"]
			end
			if q[1]["oreLevel"] != nil then
				UpgradeTable[ply:SteamID()]["Ore Lasers"] = q[1]["oreLevel"]
			end
			if q[1]["iceLevel"] != nil then
				UpgradeTable[ply:SteamID()]["Ice Lasers"] = q[1]["iceLevel"]
			end
			if q[1]["refinerLevel"] != nil then
				UpgradeTable[ply:SteamID()]["Refiner Level"] = q[1]["refinerLevel"]
			end
			--print( q[1]["icePercent"] )
			print(nick .. " Loaded successfully")

			net.Start( "Hax.TeamValue")
			net.WriteInt( q[1]["team"], 8 )
			net.WriteFloat( q[1]["score"])
			net.WriteFloat( q[1]["money"])
			net.Send( ply )

			ply:Kill()
		end
	end
	Query:start()
end

function GM:PlayerAuthed( ply, steamid, uniqeid )
		UpgradeTable[ply:SteamID()] = {}
		UpgradeTable[ply:SteamID()]["Tiberium Drills"] = 0
		UpgradeTable[ply:SteamID()]["Ore Lasers"] = 0
		UpgradeTable[ply:SteamID()]["Ice Lasers"] = 0
		UpgradeTable[ply:SteamID()]["Refiner Level"] = 0

		initDatabase( ply, steamid, ply:Nick() )
end

function GM:PlayerInitialSpawn( ply )
	ply:SetGravity( 1 )
	ply:SetWalkSpeed( 250 )
	ply:SetRunSpeed( 300 )
	ply:SetCrouchedWalkSpeed( 0.3 )
	ply:SetDuckSpeed( 0.5 )
	ply:SetNoCollideWithTeammates( false )

	local message = " Welcome to the server dickhead!, We're keeping our eyes on you, mister " .. ply:Nick()
	ply:SendLua( "chat.AddText( Color( 0, 0, 255 ), [[ " .. message .." ]]  )")

	miningLaserTable[ply:SteamID()] = {}
end

function GM:PlayerLoadout( ply )
	ply:Give("gmod_tool")
	ply:Give("weapon_physgun")
end

function GM:CanPlayerSuicide()
	return true
end

function GM:PlayerSetModel( ply )

	if ply:Team() == 1 || ply:Team() == 2 then
		PlySetTeam( ply:Team(), ply )

		local message = " Welcome to the Ore Faction "
		ply:SendLua( "chat.AddText( Color( 0, 0, 255 ), [[ " .. message .." ]]  )")

	elseif ply:Team() == 3 || ply:Team() == 4 then
		PlySetTeam( ply:Team(), ply )

		local message = " Welcome to the Tiberium Religion "
		ply:SendLua( "chat.AddText( Color( 0, 0, 255 ), [[ " .. message .." ]]  )")
	end
end

function spawnPlayer( PlayerTeam )
	--ply:ChatPrint( ply:Team() )
	if string.find( game.GetMap(), "twinsuns", 1, false ) != 0 then
		if PlayerTeam == 1 then
		--Starfleet_Ore
			return Vector( -10795.797852, -7824.564453, -687.968750 )

		elseif PlayerTeam == 2 then
		--Pirate_Ore
			return Vector( -10256.934570, -8288.608398, -687.968750 )

		elseif PlayerTeam == 3 then
		--StarFleet_Tiberium
			return Vector( -10795.797852, -7824.564453, -687.968750 )

		else
		--Pirate_Tiberiums
			return Vector( -10256.934570, -8288.608398, -687.968750 )
		end
	end
end

function GM:PlayerSelectSpawn( ply )
	if ply:Team() == 0 then
		local r = math.Round( math.Rand( 1, 4 ), 0 )
		PlySetTeam( r, ply )
	else
		PlySetTeam( ply:Team(), ply)
	end
	ply:SetPos( spawnPlayer( ply:Team() ) )

end

function GM:PlayerDisconnected( ply )
	local nameChange = db:prepare("UPDATE users SET name='"..ply:Nick().."', score='"..ply:GetPData("Hax.SpacePirates.Score").."', team='"..ply:Team().."', money='"..ply:GetPData("Hax.SpacePirates.Money").."' WHERE steamid='"..ply:SteamID().."';")
	nameChange:start()
	print(ply:Nick() .. " Updated in the Database to " .. ply:Team() )
	timer.Remove("Hax.MiningLaserTimer." .. ply:Name() )
	for k,v in pairs(table.GetKeys(miningLaserTable)) do
		if v == ply:SteamID() then
			for a,b in pairs(miningLaserTable[v]) do
				b:Remove()
			end
			table.remove( miningLaserTable, k )
			break
		end
	end
	--print( "Updated" )
end

function GM:ShowSpare1( ply )
	net.Start("Hax.TeamMenu")
	net.Send( ply )
end

function GM:PhysgunPickup( ply, ent )
	if ply:IsAdmin() and ent:GetClass():lower() == "tiberium" then
		return true
	elseif  ent:GetClass():lower() != "tiberium" then
		return true
	end
end

net.Receive( "Hax.TeamSelect", function(len, ply)
	ply:SetTeam( net.ReadType() )
	ply:Kill()	
end )

function GM:Initialize()
	print("Loadede")
	timer.Simple( 10, setupSpaceAge ) --setup for terminal spawning, dosent work if run to early therefor the timer.
end

net.Receive( "Hax.ScoreBoard.GetScore", function( len, ply ) 
	local playerTable = player.GetAll()
	local scoreTable = {}
	for k,v in pairs( playerTable ) do
		scoreTable[k] = v:GetPData("Hax.SpacePirates.Score")
	end

	net.Start("Hax.ScoreBoard.RecieveScore")
	net.WriteTable( playerTable )
	net.WriteTable( scoreTable )
	net.Send( ply )
end)