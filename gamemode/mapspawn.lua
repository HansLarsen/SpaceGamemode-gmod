print("Spawning Script is online!")

local centerPointOre = { Vector(-7655.021484, 5972.894043, 902.778931), Vector(-10553.804688, 1444.701660, -1082.392700), Vector(-723.292969, 9101.095703, -730.052490) }
local centerPointIce = Vector(12808.643555, 7932.768066, 1625.251465)
local centerPointTiberium = Vector(9745.880859, -8696.584961, -8422.865234)
local automats = {{ 
    Vector(-8470,-6890,62), Vector(-7140,-7100,62) --upgrade vendors
},{ 
    Vector(-8495,-7184,62), Vector(-7140,-6880,62) --selling terminals
},{ 
    Angle(0,-45,0.000000), Angle(0,-180,0.000000) 
},{ 
    Angle(0,-0,0.000000), Angle(0,-135,0.000000) 
}}

function setupSpaceAge()
    print("Terminal spawned")
    local anglesTable = automats[3]
    for a,b in pairs(automats[1]) do
        local tempo = ents.Create("vendor upgrades")
        if !IsValid(tempo) then continue end
        tempo:SetPos(b)
        tempo:SetAngles(anglesTable[a])
        tempo:Spawn()
        tempo:GetPhysicsObject():EnableMotion(false)
        if CPPI then
            tempo:SetNWString("Owner","World")
        end
    end
    anglesTable = automats[4]
    for a,b in pairs(automats[2]) do
        local tempo = ents.Create("vendor automat")
        if !IsValid(tempo) then continue end
        tempo:SetPos(b)
        tempo:SetAngles(anglesTable[a])
        tempo:Spawn()
        tempo:GetPhysicsObject():EnableMotion(false)
        if CPPI then
            tempo:SetNWString("Owner","World")
        end
    end
end

function spawnVectorTableOre(vecTable)
    for k,v in pairs(vecTable) do
        local tempo = ents.Create("ore asteroid")
        if !IsValid(tempo) then continue end
        tempo:SetPos(v)
        tempo:Spawn()
        if CPPI then
            tempo:SetNWString("Owner","World")
        end
    end
end

function spawnVectorTableIce(vecTable)
    for k,v in pairs(vecTable) do
        local tempo = ents.Create("ice asteroid")
        if !IsValid(tempo) then continue end
        tempo:SetPos(v)
        tempo:Spawn()
        if CPPI then
            tempo:SetNWString("Owner","World")
        end
    end
end

function spawnVectorTableTiberium(vecTable)
    for k,v in pairs(vecTable) do
       local tempo = ents.Create("tiberium")
       if !IsValid(tempo) then continue end
       tempo:SetPos(v)
       tempo:Spawn()
        if CPPI then
            tempo:SetNWString("Owner","World")
        end
    end
end

local lastNumber = 0
function AsteroidUpdater()
    --print("Running")
    --PrintTable(IceStorage)
    --PrintTable(AsteroidStorage)
    --PrintTable(TiberiumStorage)
    if table.Count(AsteroidStorage) < 15 then
        local spawning = math.Rand( 0, 10 )
        local tempNumer = math.Round( math.Rand(1, table.Count(centerPointOre)) )
        ::retry::
        if lastNumber == tempNumer then
            tempNumer = math.Round( math.Rand(1, table.Count(centerPointOre)) )
            goto retry
        end
        local thingsInTheWay = ents.FindInSphere( centerPointOre[tempNumer], 3000 )
        local toBeSpawned = {}
        for i=1, spawning do
            local tempLocation = Vector( math.Rand( -1000, 1000 ), math.Rand( -3000, 3000 ), math.Rand( -2000, 2000 ) ) + centerPointOre[tempNumer]
            local fail = 0
            for k,v in pairs(thingsInTheWay) do
                if tempLocation:Distance( thingsInTheWay[k]:GetPos() ) < 100 then
                    fail = 1
                end
            end
            if fail == 1 then
                continue
            end
            toBeSpawned[table.Count(toBeSpawned) + 1] = tempLocation
        end
        --PrintTable(toBeSpawned)
        spawnVectorTableOre(toBeSpawned)
    end

    if table.Count(IceStorage) < 10 then
        local spawning = math.Rand( 0, 10 )
        local thingsInTheWay = ents.FindInSphere( centerPointIce, 1500 )
        local toBeSpawned = {}
        for i=1, spawning do
            local tempLocation = Vector( math.Rand( -1000, 1000 ), math.Rand( -1000, 1000 ), math.Rand( -1000, 1000 ) ) + centerPointIce
            local fail = 0
            for k,v in pairs(thingsInTheWay) do
                if tempLocation:Distance( thingsInTheWay[k]:GetPos() ) < 300 then
                    fail = 1
                end
            end
            if fail == 1 then
                continue
            end
            toBeSpawned[table.Count(toBeSpawned) + 1] = tempLocation
        end
        --PrintTable(toBeSpawned)
        spawnVectorTableIce(toBeSpawned)
    end

    if table.Count(TiberiumStorage) < 10 then
        local spawning = math.Rand( 0, 10 )
        local thingsInTheWay = ents.FindInSphere( centerPointTiberium, 1500 )
        local toBeSpawned = {}
        for i=1, spawning do
            local tempLocation = Vector( math.Rand( -1000, 1000 ), math.Rand( -1000, 1000 ), 0 ) + centerPointTiberium
            local fail = 0
            for k,v in pairs(thingsInTheWay) do
                if tempLocation:Distance( thingsInTheWay[k]:GetPos() ) < 10 then
                    fail = 1
                end
            end
            if fail == 1 then
                continue
            end
            toBeSpawned[table.Count(toBeSpawned) + 1] = tempLocation
        end
        --PrintTable(toBeSpawned)
        spawnVectorTableTiberium(toBeSpawned)
    end
end

function AsteroidShower() 
    PrintTable(IceStorage)
    PrintTable(AsteroidStorage)
    PrintTable(TiberiumStorage)
end

function AsteroidClear() 
    IceStorage = {}
    AsteroidStorage = {}
    TiberiumStorage = {}
    PrintTable(IceStorage)
    PrintTable(AsteroidStorage)
    PrintTable(TiberiumStorage)
end

timer.Create( "Hax.Spaceage.OreSpawner", 60, 0, AsteroidUpdater )
concommand.Add( "update", AsteroidUpdater )
concommand.Add( "show", AsteroidShower )
concommand.Add( "clearTables", AsteroidClear )
concommand.Add( "setup", setupSpaceAge )