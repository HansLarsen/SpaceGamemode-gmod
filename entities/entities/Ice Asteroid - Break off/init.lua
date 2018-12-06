AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	--print( randomSize )
	self:SetModel("models/props_junk/PopCan01a.mdl")
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

	self:SetVar( "Ice", math.Round( math.Rand( 0, 5 ) ) )

	--print( self.Entity:GetClass() )

	timer.Create("Hax.IceBreakOff." .. self.Entity:GetCreationID(), 2, 1, function() self.Entity:Remove() end)
end

function ENT:OnRemove()
	if timer.Exists("Hax.IceBreakOff." .. self.Entity:GetCreationID()) then
		timer.Remove("Hax.IceBreakOff." .. self.Entity:GetCreationID())
	end
end