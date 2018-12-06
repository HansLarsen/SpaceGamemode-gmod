include("shared.lua")

local selfEntity = self

function ENT:Initialize()
	local selfEntity = self
end

function ENT:Draw()
	self:DrawModel()
end

net.Receive( "Hax.MiningLaserSound", function()
	selfEntity:EmitSound("Hax.MiningLaserSound2")
end )