AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local UPrices = {}
UPrices["Ore Lasers"] = 200
UPrices["Tiberium Drills"] = 200
UPrices["Ice Lasers"] = 200
UPrices["Refiner Level"] = 200

local translation = {}
translation["Ore Lasers"] = "tiberiumLevel"
translation["Tiberium Drills"] = "oreLevel"
translation["Ice Lasers"] = "iceLevel"
translation["Refiner Level"] = "refinerLevel"

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel("models/sbep_community/d12consolert.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Use( activator, caller, useType, value )
	--PrintTable(UpgradeTable)
	net.Start("Hax.Terminal.Upgrades")
	net.WriteTable(UpgradeTable[activator:SteamID()])
	net.Send(activator)
end

net.Receive( "Hax.Terminal.Upgrades.Buy", function(len, ply )
	local res = net.ReadString()
	local money = tonumber( ply:GetPData("Hax.SpacePirates.Money") )
	local currentLevel = UpgradeTable[ply:SteamID()][res]
	local cost = ( currentLevel + 1 ) * UPrices[res]
	if money >= cost then
		ply:SetPData("Hax.SpacePirates.Money", money - cost)
		UpgradeTable[ply:SteamID()][res] = currentLevel + 1
	end

	net.Start( "Hax.TeamValue")
	net.WriteInt( ply:Team(), 8 )
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Score"))
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Money"))
	net.Send( ply )

	--PrintTable(UpgradeTable)
	net.Start("Hax.Terminal.Upgrades")
	net.WriteTable(UpgradeTable[ply:SteamID()])
	net.Send(ply)

	db:ping()

	local updateChange = db:prepare("UPDATE users SET "..translation[res].."='"..(currentLevel + 1).."' WHERE steamid='"..ply:SteamID().."';")
	updateChange:start()
end )
net.Receive( "Hax.Terminal.Upgrades.Sell", function(len, ply)
	local res = net.ReadString()
	local money = ply:GetPData("Hax.SpacePirates.Money")
	local currentLevel = UpgradeTable[ply:SteamID()][res]
	local cost = currentLevel * UPrices[res]
	if currentLevel > 0 then
		ply:SetPData("Hax.SpacePirates.Money", money + cost)
		UpgradeTable[ply:SteamID()][res] = currentLevel - 1
	end

	net.Start( "Hax.TeamValue")
	net.WriteInt( ply:Team(), 8 )
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Score"))
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Money"))
	net.Send( ply )

	--PrintTable(UpgradeTable)
	net.Start("Hax.Terminal.Upgrades")
	net.WriteTable(UpgradeTable[ply:SteamID()])
	net.Send(ply)
end )