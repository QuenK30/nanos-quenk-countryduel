Events.Subscribe("InDuel", function ()
    Client.SetMouseEnabled(true)
    Client.SetInputEnabled(true)
end)
Events.Subscribe("NotDuel", function ()
    Client.SetMouseEnabled(false)
    Client.SetInputEnabled(false)
end)


Client.SetSteamRichPresence("CountryDuel - Made by QuenK")
Client.SetDiscordActivity("CountryDuel - Made by QuenK", "Playing CountryDuel","", "CountryDuel")