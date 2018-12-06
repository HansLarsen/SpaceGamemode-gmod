AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos + Vector(0,0,90) )
	ent:SetAngles( SpawnAng )

	--PrintTable(tableTemp)

	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel("models/props_wasteland/coolingtank01.mdl")
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

	RD.AddResource( self.Entity, "ice", 500, 0)

	self.Outputs = Wire_CreateOutputs(self.Entity, {})

end

function ENT:OnRemove()
	RD.Unlink( self.Entity )
end