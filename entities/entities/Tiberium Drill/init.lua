AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheSound("ambience/mechwhine.wav")
util.PrecacheSound("buttons/button2.wav")

sound.Add( { name = "Hax.TiberiumDrillSound4", channel = CHAN_AUTO, volume = 1.0, level = 70, pitch =  95 , sound = "ambience/mechwhine.wav" } )
sound.Add( { name = "Hax.TiberiumDrillSound5", channel = CHAN_AUTO, volume = 1.0, level = 70, pitch =  95 , sound = "buttons/button2.wav" } )
--miningLaserTable is declared in the init.lua in the gamemode--
baseMiningRate = 2
energyUse = 5000

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
	local ply = self:GetTable()["m_PlayerCreator"]
	if ply.drills == true then
		self:Remove()
		return
	end
	self.BaseClass.Initialize(self)
	self:SetModel("models/slyfo/rover_drillbit.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()

	self.steamid = ply:SteamID()

	if phys:IsValid() then
		phys:Wake()
	end

	--adding the lasers self to the global table for updating--
	local tempTable = {}
	tempTable = miningLaserTable[ply:SteamID()]
	tempTable[table.Count(tempTable) + 1] = self.Entity
	miningLaserTable[ply:SteamID()] = tempTable
	
	ply.drills = true

	--Registering the wiremod inputs and outputs--
	self.Inputs = Wire_CreateInputs(self.Entity, {"Start"})
    self.Outputs = Wire_CreateOutputs(self.Entity, {})

    --RD.AddResource(self.Entity, "energy", energyUse, 0)
    RD.RegisterNonStorageDevice(self.Entity)

	--self:SetTrigger( true )
end
--the function for calculation the bonus depending on team and personal bonus--
function ENT:MiningBonus( stringTemp )
	local owner = self:GetTable()["m_PlayerCreator"]
	local teamBonus = 0;
	local stringTemp2 = ""
	if stringTemp == "tiberium" then
		stringTemp2 = "Hax.SpacePirates.tiberiumPercent"
		if owner:Team() == 2 || owner:Team() == 4 then
			teamBonus = 3 * UpgradeTable[ply:SteamID()]["Ore Lasers"]
		end
	end
	local personalBonus = owner:GetPData( stringTemp2 )
	return ( baseMiningRate + teamBonus ) + ( ( baseMiningRate + teamBonus ) * ( personalBonus / 100 ) ) -- no idea on if lua respects the order of operations, but i assume not--
end

function ENT:Updater()
	local tempTime = math.Rand(0, 2)
	timer.Simple( tempTime, function()
		if !IsValid( self.Entity ) then
			return
		end
		self.touching = self.Entity:GetVar("Hax.TouchingTiberiumDrill", nil)
		if !IsValid( self.touching ) then
			--print( "No!" )
			return
		else
			--print(self.touching)
		end
		if self.Inputs.Start.Value != 0 && self.touching:GetClass() == "tiberium" then
			--The mining lasers randomly uses more power--
			local energy = energyUse * math.Rand( 0.5, 2 )
			if RD.ConsumeResource(self.Entity, "energy", energy ) != energy then
				self:EmitSound("hax.TiberiumDrillSound5")
				return
			end
			local mining = self:MiningBonus( "tiberium" )
			local ore = self.touching:GetVar( "Tiberium" )
			--print(ore)
			if ore < 0 then
				self.touching:Remove()
				return
			end
			--Removing the ore from the asteroid--
			self.touching:SetVar( "Tiberium", ore - mining )
			RD.SupplyResource(self.Entity, "tiberium", mining )
			self:EmitSound("hax.TiberiumDrillSound4")
		end
	end )
end
--removing it self from the miningLaserTable on deletesion--
function ENT:OnRemove()
	for k,v in pairs( miningLaserTable ) do
		if k == self.steamid then
			for l,b in pairs( v ) do
				if b == self then
					table.remove(miningLaserTable[k], l)
					self:GetTable()["m_PlayerCreator"].drills = false
					return
				end 
			end
		end
	end
end