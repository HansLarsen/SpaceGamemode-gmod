AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--miningLaserTable is declared in the init.lua in the gamemode--
baseMiningRate = 2
energyUse = 10000
steamUse = 200
waterUse = 200

local RD = CAF.GetAddon("Resource Distribution")

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos + Vector(0,0,30) )
	ent:SetAngles( SpawnAng )

	local tableTemp = {}
	tableTemp = ent:GetTable()
	tableTemp["m_PlayerCreator"] = ply
	ent:SetTable(tableTemp)

	--PrintTable(tableTemp)

	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel("models/slyfo_2/mini_turret_surgilaser.mdl")
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
	--Registering the wiremod inputs and outputs--
	self.Inputs = Wire_CreateInputs(self.Entity, {"Shoot"})
    self.Outputs = Wire_CreateOutputs(self.Entity, {})

    --RD.AddResource(self.Entity, "energy", energyUse, 0)
    RD.RegisterNonStorageDevice(self.Entity)
end
--triggering on wire input
function ENT:TriggerInput( iname, value )
	if iname == "Shoot" && value == 1 then 
		--print( "Triggered" )
		local traceTable = {}
		--Table for shooting the tracer, settings the tracers positions based on the entities model--
		traceTable["start"] = self:LocalToWorld( Vector( 145, 1, 0 ) )
		traceTable["endpos"] = self:LocalToWorld( Vector( 500, 1, 0 ) )
		traceTable["fileter"] = function( ent ) --fileter is the way its spellede on the wiki--
			if ent != self && ent:GetClass() == "prop_physics" then 
				return true 
			else
				return false
			end 
		end
		--the tracer itself--
		local hit = util.TraceLine( traceTable )
		--print( hit["Entity"] )
		--Checking if the entity the tracer has hit is valid and if its a asteroid--
		if hit["Entity"]:IsValid() && hit["Entity"]:GetClass() == "ice asteroid - break off" then
			--print("Hit")
			--The mining lasers randomly uses more power--
			RD.ConsumeResource(self.Entity, "energy", energyUse * math.Rand( 0, 2 ) )
			RD.SupplyResource(self.Entity, "ice", hit["Entity"]:GetVar( "Ice" ) )
			hit["Entity"]:Remove()
		end
	end
end