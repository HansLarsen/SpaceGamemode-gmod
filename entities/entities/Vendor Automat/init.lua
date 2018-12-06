AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")
local teams = {"Starfleet_Ore", "Pirate_Ore", "StarFleet_Tiberium", "Pirate_Tiberium"}

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos + Vector(0,0,0) )
	ent:SetAngles( SpawnAng )

	--PrintTable(tableTemp)

	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel("models/sbep_community/d12console.mdl")
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
	local resources = {}
	resources["playerData"] = {}
	local nodes = ents.FindByClass( "resource_node" )
	for k,v in pairs(nodes) do
		if v:CPPIGetOwner() != caller || self.Entity:GetPos():Distance( v:GetPos() ) > 3000 then
			table.remove( nodes, k )
		end 
	end
	if IsValid(nodes[1]) then
		caller.node = nodes[1]
		local nettable = RD.GetNetTable(nodes[1].netid)
		resources["resources"] = nettable["resources"]
	else
		resources["resources"] = {}
	end
	resources["playerData"]["Money"] = caller:GetPData("Hax.SpacePirates.Money")
	resources["playerData"]["Score"] = caller:GetPData("Hax.SpacePirates.Score")
	resources["playerData"]["Team"] = teams[caller:Team()]

	net.Start("Hax.Terminal")
	net.WriteTable( resources )
	net.Send( caller )
	--print( caller )
end

net.Receive( "Hax.Terminal.Sell", function(len, ply)
	local typeRes = net.ReadString()
	local amountRes = net.ReadFloat()
	local priceRes = net.ReadInt(10)
	local usedRes = RD.ConsumeNetResource(ply.node.netid, typeRes, amountRes)
	ply:SetPData("Hax.SpacePirates.Money", tonumber( ply:GetPData("Hax.SpacePirates.Money") ) + ( usedRes * priceRes ) )
	ply:SetPData("Hax.SpacePirates.Score", tonumber( ply:GetPData("Hax.SpacePirates.Score") ) + usedRes )

	net.Start( "Hax.TeamValue")
	net.WriteInt( ply:Team(), 8 )
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Score") )
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Money") )
	net.Send( ply )
end )

net.Receive( "Hax.Terminal.Buy", function(len, ply)
	local typeRes = net.ReadString()
	local amountRes = net.ReadFloat()
	local priceRes = net.ReadInt(10)
	local plyMoney = tonumber( ply:GetPData("Hax.SpacePirates.Money") )
	--print(priceRes)
	if plyMoney > ( priceRes * amountRes ) && ( priceRes * amountRes ) != 0 then
		ply:SetPData("Hax.SpacePirates.Money", plyMoney - (amountRes * priceRes) )
		RD.SupplyNetResource(ply.node.netid, typeRes, amountRes)
	end

	net.Start( "Hax.TeamValue")
	net.WriteInt( ply:Team(), 8 )
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Score"))
	net.WriteFloat( ply:GetPData("Hax.SpacePirates.Money"))
	net.Send( ply )
end )