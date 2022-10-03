
Package.RequirePackage("rounds")

Package.Require("Config.lua")

Client.SetSteamRichPresence("CountryDuel - Made by QuenK & Voltaism")
Client.SetDiscordActivity("CountryDuel - Made by QuenK & Voltaism", "Playing CountryDuel","https://i.imgur.com/IN8V6Q6.png", "CountryDuel")

local country_canvas = Canvas(
    true,
    Color.TRANSPARENT,
    0,
    true
)

country_canvas:Subscribe("Update", function(self, width, height)
    
end)

WAITING_STRING = {
    [1] = "Waiting for players",
    [2] = "Waiting for players.",
    [3] = "Waiting for players..",
    [4] = "Waiting for players..."
}
