Package.RequirePackage("nanos-world-weapons")
Package.Require("Config.lua")

local player_one = nil
local player_two = nil
local player_one_char = nil
local player_two_char = nil
local player = 0
local spawn_one = SPAWN_ONE
local spawn_two = SPAWN_TWO
local time_game = TIME_GAME
local time_until_duel = TIME_UNTIL_DUEL
function TeleportStartGame(player)
    if (not player or not player:IsValid()) then return end
    local char = player:GetControlledCharacter()
    local weapon = Gun()
    if player == player_one then
    char = Character(spawn_one, Rotator(0,22,0), "nanos-world::SK_Mannequin")
    char:PickUp(weapon)
    player:Possess(char)
    player_one_char = char
    player_one:SetValue("Weapon", weapon)
    elseif player == player_two then
    char = Character(spawn_two,  Rotator(0,-176,0), "nanos-world::SK_Mannequin")
    char:PickUp(weapon)
    player:Possess(char)
    player_two_char = char
    player_two:SetValue("Weapon", weapon)
    end
end

Player.Subscribe("Spawn", function(new_player)
        player = player + 1
    if player_one == nil then
        player_one = new_player
        print("Player 1 is " .. player_one:GetName())
    else
        player_two = new_player
        print("Player 2 is " .. player_two:GetName())
    end

    print("Player "..player.." connected")
    if player == 2 then
        Server.BroadcastChatMessage("Two players connected, starting game")
        Server.BroadcastChatMessage("Opponents are " .. player_one:GetName() .. " and " .. player_two:GetName())
        Server.BroadcastChatMessage("Game will start in " .. time_until_duel .. " seconds")
        
        Events.Call("StartGame")
    end
end)

Player.Subscribe("Destroy", function(player)
    local character = player:GetControlledCharacter()
    if (character) then
        character:Destroy()
        player = player-1
    end
end)

function Gun()
    local weapon = NanosWorldWeapons.DesertEagle(Vector(), Rotator())
    weapon:SetDamage(150)
    weapon:SetAmmoSettings(8,0)
    return weapon
end



function MoveDuel(player)
    if (not player or not player:IsValid()) then return end
    local char = player:GetControlledCharacter()
    Timer.SetTimeout(function ()
        if player == player_one then
            player:UnPossess()
            char:MoveTo(ONE_MOVE, 1)
            player:AttachCameraTo(char, Vector(0,0,0), 0)
            elseif player == player_two then
            player:UnPossess()
            char:MoveTo(TWO_MOVE, 1)
            player:AttachCameraTo(char, Vector(0,0,0), 0)
            end
    end, TIME_UNTIL_MOVE * 1000)
end
Events.Subscribe("StartGame", function(ply)
    print("Game started")
    TeleportStartGame(player_one)
    TeleportStartGame(player_two)
    MoveDuel(player_one)
    MoveDuel(player_two)
    Timer.SetTimeout(function ()
        Server.BroadcastChatMessage("<red> Fight begin !</>")
        Events.Call("Game")
    end, time_until_duel*1000)
end)

Events.Subscribe("Game", function(ply)
    Timer.SetTimeout(function ()
        Server.BroadcastChatMessage("<red> Fight finish !</>")
        Events.Call("EndGame")
    end, time_game*1000)
end)

Events.Subscribe("EndGame", function(ply)
    --Destroy Weapon
    local weapon_one = player_one:GetValue("Weapon")
    local weapon_two = player_two:GetValue("Weapon")
    Timer.SetTimeout(function ()
        if weapon_one and weapon_one:IsValid() then
            weapon_one:Destroy()
        end
        if weapon_two and weapon_two:IsValid() then
            weapon_two:Destroy()
        end
    
    
            player_one:UnPossess()
            player_two:UnPossess()
            player_one:Kick("Game finished")
            player_two:Kick("Game finished")
            player_one = nil
            player_two = nil
            player_one_char:Destroy()
            player_two_char:Destroy()
            player_one_char = nil
            player_two_char = nil
            player = 0
    end, TIME_UNTIL_ROUND * 1000)

end)

Character.Subscribe("Death", function(self, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)

        if self == player_one_char then
            Server.BroadcastChatMessage("<red>"..player_two:GetAccountName().." won!</>")
            Events.Call("EndGame")
        elseif self == player_two_char then
            Server.BroadcastChatMessage("<red>"..player_one:GetAccountName().." won!</>")
            Events.Call("EndGame")
        end
end)

Character.Subscribe("MoveCompleted", function(self, succeeded)

    if self == player_one_char then
        player_one:Possess(self)
        player_one_char:SetViewMode(ViewMode.FPS)
        player_one_char:SetSpeedMultiplier(0)
    elseif self == player_two_char then
        player_two:Possess(self)
        player_two_char:SetViewMode(ViewMode.FPS)
        player_two_char:SetSpeedMultiplier(0)

    end
end)

Character.Subscribe("ViewModeChanged", function(self, old_state, new_state)
    return true
end)