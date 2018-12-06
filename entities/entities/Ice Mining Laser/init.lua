AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheSound("beams/beamstart5.wav")
util.PrecacheSound("buttons/button2.wav")

sound.Add( { name = "Hax.MiningLaserSound6", channel = CHAN_AUTO, volume = 1.0, level = 50, pitch =  95 , sound = "beams/beamstart5.wav" } )
sound.Add( { name = "Hax.MiningLaserSound7", channel = CHAN_AUTO, volume = 1.0, level = 50, pitch =  95 , sound = "buttons/button2.wav" } )
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
	self:SetModel("models/slyfo/sat_laser.mdl")
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
	self.Inputs = Wire_CreateInputs(self.Entity, {"Start"})
    self.Outputs = Wire_CreateOutputs(self.Entity, {})

    --RD.AddResource(self.Entity, "energy", energyUse, 0)
    RD.RegisterNonStorageDevice(self.Entity)
	
	--self:PostEntityPaste(self:GetTable()["m_PlayerCreator"], self.Entity, 0 )
end
function ENT:PostEntityPaste( ply, ent, createdEntities )
	self:GetTable()["m_PlayerCreator"] = ply
	if ply.icelasers == true then
		self:Remove()
		return
	end
	ply.icelasers = true
	self.steamid = ply:SteamID()
	--adding the lasers self to the global table for updating--
	local tempTable = {}
	tempTable = miningLaserTable[self.steamid]
	tempTable[table.Count(tempTable) + 1] = self.Entity
	miningLaserTable[self.steamid] = tempTable
end
--the function for calculation the bonus depending on team and personal bonus--
function ENT:MiningBonus( stringTemp )
	local owner = self:GetTable()["m_PlayerCreator"]
	local teamBonus = 0;
	local stringTemp2 = ""
	if stringTemp == "ice" then
		stringTemp2 = "Hax.SpacePirates.icePercent"
		teamBonus = baseMiningRate * UpgradeTable[owner:SteamID()]["Ice Lasers"]
	end
	local personalBonus = owner:GetPData( stringTemp2 )
	return ( baseMiningRate + teamBonus ) + ( ( baseMiningRate + teamBonus ) * ( personalBonus / 100 ) ) -- no idea on if lua respects the order of operations, but i assume not--
end
--all the entities reqistered in the MiningLaserTables has to have this function for them to be updatede--
function ENT:Updater()
	local tempTime = math.Rand(0, 2)
	timer.Simple( tempTime, function() --Timer to make the running of the drill more random--
		if !IsValid( self.Entity ) then
			return
		end
		if self.Inputs.Start.Value != 0 then --checking if the wire input is on--
			if RD.ConsumeResource(self.Entity, "energy", energyUse ) < energyUse then --mining laser always consumes power no matter if a target is found--
				self:EmitSound("Hax.MiningLaserSound7")
				return
			end
			local effectdata = EffectData()
			local traceTable = {}
			--SpaceBuild Life Support Reources--
			--self:ConsumeResource("energy", energyUse )
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
			if hit["Entity"]:IsValid() && hit["Entity"]:GetClass() == "ice asteroid" then
				local bonus = 1
				--The mining lasers randomly uses more power--
				RD.ConsumeResource(self.Entity, "energy", energyUse * math.Rand( 0, 2 ) )
				--Gets a bonus if theres water and steam--
				if RD.ConsumeResource(self.Entity, "water", waterUse ) == waterUse && RD.ConsumeResource(self.Entity, "steam", steamUse ) == steamUse then
					bonus = 1.25
				end

				self:EmitSound("Hax.MiningLaserSound6")
				--Getting the ore amount from the astroid to check it it needs to be destroyed--
				local ore = hit["Entity"]:GetVar( "Ice" )
				--print(ore)
				if ore < 0 then
					hit["Entity"]:Remove()
					return
				end
				local breakoffspawn = Vector(math.Rand(-200, 200), math.Rand(-200, 200), math.Rand(-200, 200))
				local iceBreakOff = ents.Create("ice asteroid - break off")
				iceBreakOff:SetPos(hit["Entity"]:LocalToWorld(breakoffspawn))
				iceBreakOff:Spawn()
				--Removing the ore from the asteroid--
				hit["Entity"]:SetVar( "Ice", ore - ( self:MiningBonus( "ice" ) * bonus )  )
				RD.SupplyResource(self.Entity, "ice", ( self:MiningBonus( "ice" ) * bonus ) )
				--The effects to be played on the astroid and so on--
				effectdata:SetOrigin( traceTable["start"] )
				effectdata:SetStart( hit["HitPos"] )
			else
				effectdata:SetOrigin( traceTable["endpos"] )
				effectdata:SetStart( traceTable["start"] )
			end
			util.Effect( "ToolTracer", effectdata )
		end
	end )
end
--removing it self from the miningLaserTable on deletesion--
function ENT:OnRemove()
	--print( "Cakeis a lie: " .. self.steamid)
	for k,v in pairs( miningLaserTable ) do
		if k == self.steamid then
			for l,b in pairs( v ) do
				if b == self then
					table.remove(miningLaserTable[k], l)
					self:GetTable()["m_PlayerCreator"].icelasers = false
					return
				end 
			end
		end
	end
end