DeriveGamemode( "sandbox" )

GM.Name = "PepiHax"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

function GM:Initialize()
	self.BaseClass.Initialize( self )
end

local Starfleet_Ore, Pirate_Ore, StarFleet_Tiberium, Pirate_Tiberium = 1, 2, 3, 4

team.SetUp( 1, "StarFleet. A Ore Specialist", Color(255,0,0,255))
team.SetUp( 2, "Pirate. Ore Specialist", Color(255,0,0,255))
team.SetUp( 3, "StarFleet. In the Tiberium Religion", Color(0,255,0,255))
team.SetUp( 4, "Pirate. In the Tiberium Religion", Color(0,255,0,255))
team.SetUp( 5, "You disgust me", Color(0,0,0,255)) 

util.PrecacheModel("models/breen.mdl")
util.PrecacheModel("models/mossman.mdl")
util.PrecacheModel("models/Kleiner.mdl")
util.PrecacheModel("models/gman_high.mdl")
util.PrecacheModel("models/Barney.mdl")
util.PrecacheModel("models/odessa.mdl")