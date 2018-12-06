AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

IceStorage = {}

function ENT:Initialize()
	--print( randomSize )
	self:SetModel("models/spacebuild/strange.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_OBB)
	self:DrawShadow(false)

	self:SetVar( "Ice", math.Round( math.Rand( 0, 3000 ) ) )

	--print( self.Entity:GetClass() )
	self.tableIndex = table.Count(IceStorage) + 1
	IceStorage[self.tableIndex] = self.Entity
end

function ENT:OnRemove()
	table.remove( IceStorage, self.tableIndex ) 
end