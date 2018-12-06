AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

AsteroidStorage = {}

function ENT:Initialize()
	local randomSize = math.Round( math.Rand( 0, 100 ) )
	--print( randomSize )
	if randomSize > 95 then
		self:SetModel("models/ce_ls3additional/asteroids/asteroid_350.mdl")
		self:SetVar( "Ore", math.Round( math.Rand( 2500, 3000 ) ) )
	elseif randomSize > 75 then
		self:SetModel("models/ce_ls3additional/asteroids/asteroid_300.mdl")
		self:SetVar( "Ore", math.Round( math.Rand( 2000, 2500 ) ) )
	elseif randomSize > 40 then
		self:SetModel("models/ce_ls3additional/asteroids/asteroid_250.mdl")
		self:SetVar( "Ore", math.Round( math.Rand( 1500, 2000 ) ) )
	else
		self:SetModel("models/ce_ls3additional/asteroids/asteroid_200.mdl")
		self:SetVar( "Ore", math.Round( math.Rand( 1000, 1500 ) ) )
	end
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_OBB)
	self:DrawShadow(false)

	self.tableIndex = table.Count(AsteroidStorage) + 1
	AsteroidStorage[self.tableIndex] = self.Entity

end

function ENT:OnRemove()
	table.remove( AsteroidStorage, self.tableIndex ) 
end