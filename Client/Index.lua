local function enableInput(bEnabled)
    Client.SetInputEnabled(not bEnabled)
    print("Input enabled: " .. tostring(not bEnabled))
end

enableInput(true)

Player.Subscribe("Possess", function(player, character)
    if (player == Client.GetLocalPlayer()) then
        enableInput(true)
        print("Possessing character")
    end
end)

Player.Subscribe("UnPossess", function(player, character)
    if (player == Client.GetLocalPlayer()) then
        enableInput(false)
        print("UnPossessing character")
    end
end)

Client.SetSteamRichPresence("CountryDuel - Made by QuenK")
Client.SetDiscordActivity("CountryDuel - Made by QuenK", "Playing CountryDuel","https://i.imgur.com/IN8V6Q6.png", "CountryDuel")