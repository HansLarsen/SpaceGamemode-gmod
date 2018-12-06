AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

TiberiumStorage = {}

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos + Vector(0,0,-50) )
	ent:SetAngles( SpawnAng )

	local tableTemp = {}
	tableTemp = ent:GetTable()
	tableTemp["m_PlayerCreator"] = ply
	ent:SetTable(tableTemp)

	--PrintTable(tableTemp)

	ent:Spawn()

	return ent

end

function ENT:Initialize()
	local randomSize = math.Round( math.Rand( 100, 500 ) )
	--print( randomSize )
	self:SetModel("models/ce_ls3additional/tiberium/tiberium_normal.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetTrigger(1)
	self:GetPhysicsObject():EnableMotion(false)

	self:SetVar( "Tiberium", 200 + ( ( randomSize / 100 ) * 100 ) )
	self:SetModelScale( randomSize / 100, 0)

	self.tiberiumRise = "Hax.TiberiumRise." .. self:EntIndex()
	self.startPos = Vector(0,0,-1 * ( ( randomSize / 100 ) * 40) )
	self.endPos = Vector(0,0,40)
	self.timerToRise = math.Rand(300, 500)

	self:SetPos( self:GetPos() + self.startPos )

	timer.Create( self.tiberiumRise, 0.02, self.timerToRise, function() self:SetPos( ( (self.endPos - self.startPos ) / self.timerToRise ) + self:GetPos()  ) end )
	timer.Start( self.tiberiumRise )
	--timer.Simple(self.timerToRise + 2, function() self.Entity:Activate()  end)

	self.tableIndex = table.Count(TiberiumStorage) + 1
	TiberiumStorage[self.tableIndex] = self.Entity
end

function ENT:StartTouch( other )
	--print( other )
	if other:GetClass() == "tiberium tank" then
		return
	elseif other:IsPlayer() then
		--print( ragdoll )
		other:Kill()
	elseif other:GetClass() == "tiberium drill" then
		other:SetVar("Hax.TouchingTiberiumDrill", self.Entity)
	elseif other:GetClass() != "tiberium drill" then
		other:SetMaterial("phoenix_storms/wire/pcb_green")
		timer.Simple( 5, function() other:Remove() end )
	end
end

function ENT:EndTouch( other )
	other:SetVar("Hax.TouchingTiberiumDrill", nil)
end

function ENT:OnRemove()
	if timer.Exists(self.tiberiumRise) then timer.Destroy(self.tiberiumRise) end
    table.remove( TiberiumStorage, self.tableIndex )
end