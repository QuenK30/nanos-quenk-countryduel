
Package.RequirePackage("nanos-world-weapons")
Package.RequirePackage("rounds")

Package.Require("Config.lua")

INIT_ROUNDS({
    ROUND_TYPE = "TEAMS",
    ROUND_TEAMS = {"PASSED_TEAMS", "ROUNDSTART_GENERATION"},
    ROUND_START_CONDITION = {"PLAYERS_NB", 2},
    ROUND_END_CONDITION = {"REMAINING_PLAYERS", 1},
    SPAWN_POSSESS = {"CHARACTER"},
    SPAWNING = {"SPAWNS", {Game_Locations[1].Spawn, Game_Locations[2].Spawn}, "ROUNDSTART_SPAWN"},
    WAITING_ACTION = {"FREECAM"},
    PLAYER_OUT_CONDITION = {"DEATH"},
    PLAYER_OUT_ACTION = {"WAITING"},
    ROUNDS_INTERVAL_ms = 5000,
    MAX_PLAYERS = 10,
    CAN_JOIN_DURING_ROUND = false,
    ROUNDS_DEBUG = Country_Debug
})

local Waiting_Room = {}

Events.Subscribe("RoundPlayerJoined", function(ply)
    table.insert(Waiting_Room, ply)
end)

Player.Subscribe("Destroy", function(ply)
    for i, v in ipairs(Waiting_Room) do
        if v == ply then
            table.remove(Waiting_Room, i)
            break
        end
    end

    if (ply:GetValue("MovingChar") and ply:GetValue("MovingChar"):IsValid()) then
        ply:GetValue("MovingChar"):Destroy()
    end
end)

Events.Subscribe("ROUND_PASS_TEAMS", function()
    if (Waiting_Room[1] and Waiting_Room[2]) then
        TEAMS_FOR_THIS_ROUND = {{Waiting_Room[1]}, {Waiting_Room[2]}}
        table.remove(Waiting_Room, 1)
        table.remove(Waiting_Room, 1)
    end
end)

Events.Subscribe("RoundPlayerSpawned", function(ply)
    local char = ply:GetControlledCharacter()
    local team = ply:GetValue("PlayerTeam")
    if char then
        if team then
            char:PickUp(NanosWorldWeapons.DesertEagle())
            ply:SetValue("MovingChar", char, false)
            ply:UnPossess()
            char:MoveTo(Game_Locations[team].MoveTo, 80)
            ply:AttachCameraTo(char, Vector(0,0,0), 0)
        end
    end
end)

Character.Subscribe("MoveCompleted", function(char, success)
    if success then
        for k, v in pairs(Player.GetPairs()) do
            local m_c = v:GetValue("MovingChar")
            if m_c then
                if m_c == char then
                    v:Possess(char)
                    v:SetValue("MovingChar", nil, false)
                    char:SetSpeedMultiplier(0)
                end
            end
        end
    else
        error("MoveTo failed")
    end
end)

Events.Subscribe("RoundEnding", function()
    for k, v in pairs(Player.GetPairs()) do
        local found
        for k2, v2 in ipairs(Waiting_Room) do
            if v2 == v then
                found = true
            end
        end

        if not found then
            table.insert(Waiting_Room, v)
        end
    end

    for k, v in pairs(Weapon.GetAll()) do
        v:Destroy()
    end
end)