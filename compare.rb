require 'rubygems'
require 'json'
require 'net/http'

@green = 76561198000976107
@laggy = 76561197970651383
@steam_key = ENV['STEAM_API_KEY']

def getJSON(url)
    json = Net::HTTP.get(URI.parse(url))
    JSON.parse(json)
end

def getOwnedGames(person) 
    url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{@steam_key}&steamid=#{person}&format=json"
    getJSON(url)
end

def getAppList
    url = "http://api.steampowered.com/ISteamApps/GetAppList/v0001/"
    getJSON(url)
end

# get id to name map
appHash = Hash.new
appList = getAppList
appList["applist"]["apps"]["app"].each do |a|
    appHash[a["appid"]] = a["name"]
end


# get green's games
greenGamesRaw = getOwnedGames(@green)["response"]["games"]
greenGames = Array.new
greenGamesRaw.each do |g|
    greenGames << g["appid"]
end

# get laggy's games
laggyGamesRaw = getOwnedGames(@laggy)["response"]["games"]
laggyGames = Array.new
laggyGamesRaw.each do |g|
    laggyGames << g["appid"]
end

# get the intersection
sharedGamesIds = greenGames & laggyGames
sharedGames = Array.new
sharedGamesIds.each do |g|
    sharedGames << appHash[g]
end
sharedGames.sort!

# spit them out to screen
sharedGames.each do |g|
    puts g
end

puts sharedGames.length