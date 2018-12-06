AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.PrecacheSound("beams/beamstart5.wav")
util.PrecacheSound("buttons/button2.wav")

sound.Add( { name = "Hax.MiningLaserSound2", channel = CHAN_AUTO, volume = 1.0, level = 50, pitch =  95 , sound = "beams/beamstart5.wav" } )
sound.Add( { name = "Hax.MiningLaserSound3", channel = CHAN_AUTO, volume = 1.0, level = 50, pitch =  95 , sound = "buttons/button2.wav" } )
--miningLaserTable is declared in the init.lua in the gamemode--
miningTimerUpdater = "Hax.MiningLaserTimerUpdater"
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
	self:SetModel("models/slyfo/swordgatmid.mdl")
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

	self.teamBonus = 1
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
	if !IsValid( ply ) then
		ply = self:GetTable()["m_PlayerCreator"]
	end
	self:GetTable()["m_PlayerCreator"] = ply
	if ply.orelasers == true then
		self:Remove()
		return
	end
	self.steamid = ply:SteamID()
	--adding the lasers self to the global table for updating--
	local tempTable = {}
	tempTable = miningLaserTable[self.steamid]
	tempTable[table.Count(tempTable) + 1] = self.Entity
	miningLaserTable[self.steamid] = tempTable
	
	ply.orelasers = true
	--self:GetTable()["m_PlayerCreator"] returns the entity of the owner which is then used to determin the model of the laser--
	local ownerTeam = ply:Team()
	if ownerTeam == 2 || ownerTeam == 4 then
		if math.Round( math.Rand( 1,2 ) ) == 1 then
			self.Entity:SetModel("models/slyfo/swordgatleft.mdl")
		else
			self.Entity:SetModel("models/slyfo/swordgatright.mdl")
		end
	end
end
--the function for calculation the bonus depending on team and personal bonus--
function ENT:MiningBonus( stringTemp )
	local owner = self:GetTable()["m_PlayerCreator"]
	local teamBonus = 0;
	local stringTemp2 = ""
	if stringTemp == "ore" then
		stringTemp2 = "Hax.SpacePirates.orePercent"
		if owner:Team() == 1 || owner:Team() == 2 then
			teamBonus = 3
		end
		teamBonus = ( teamBonus * self.teamBonus ) * UpgradeTable[owner:SteamID()]["Ore Lasers"]
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
				self:EmitSound("Hax.MiningLaserSound3")
				return
			end
			local effectdata = EffectData()
			local traceTable = {}
			--SpaceBuild Life Support Reources--
			--self:ConsumeResource("energy", energyUse )

			--Table for shooting the tracer, settings the tracers positions based on the entities model--
			if self:GetModel() == "models/slyfo/swordgatmid.mdl" then
				traceTable["start"] = self:LocalToWorld( Vector( 150, 1, 0 ) )
				traceTable["endpos"] = self:LocalToWorld( Vector( 500, 1, 0 ) )
			else
				traceTable["start"] = self:LocalToWorld( Vector( 145, 1, 39 ) )
				traceTable["endpos"] = self:LocalToWorld( Vector( 500, 1, 39 ) )
			end
			traceTable["fileter"] = function( ent ) --fileter is the way its spellede on the wiki--
				if ent != self && ent:GetClass() == "prop_physics" then 
					return true 
				else
					return false
				end 
			end
			--the tracer itself--
			local hit = util.TraceLine( traceTable )
			--Checking if the entity the tracer has hit is valid and if its a asteroid--
			--print( hit["Entity"] )
			if IsValid( hit["Entity"] ) && hit["Entity"]:GetClass() == "ore asteroid" then
			
				local bonus = 1
				--The mining lasers randomly uses more power--
				RD.ConsumeResource(self.Entity, "energy", energyUse * math.Rand( 0, 2 ) )
				--Gets a bonus if theres water and steam--
				if RD.ConsumeResource(self.Entity, "water", waterUse ) == waterUse && RD.ConsumeResource(self.Entity, "steam", steamUse ) == steamUse then
					bonus = 1.25
				end

				self:EmitSound("Hax.MiningLaserSound2")
				--Getting the ore amount from the astroid to check it it needs to be destroyed--
				local ore = hit["Entity"]:GetVar( "Ore" )
				--print(ore)
				if ore < 0 then
					hit["Entity"]:Remove()
					return
				end
				--Removing the ore from the asteroid--
				hit["Entity"]:SetVar( "Ore", ore - ( self:MiningBonus( "ore" ) * bonus )  )
				RD.SupplyResource(self.Entity, "ore", ( self:MiningBonus( "ore" ) * bonus ) )
				--The effects to be played on the astroid and so on--
				local effectdata2 = EffectData()
				effectdata2:SetOrigin( hit["HitPos"] )
				util.Effect( "HelicopterMegaBomb", effectdata2 )
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
					self:GetTable()["m_PlayerCreator"].orelasers = false
					return
				end 
			end
		end
	end
end

--The function / hook to update all the lasers and tiberium drills on the server--
function traceLineLaserUpdate()
	--print( "Laser Updater")
	for k,v in pairs( miningLaserTable ) do
		--PrintTable(v)
		for l,b in pairs( v ) do
			b:Updater()
		end
	end
end

timer.Create( miningTimerUpdater, 2, 0, traceLineLaserUpdate )
timer.Start( miningTimerUpdater )