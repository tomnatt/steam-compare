require 'rubygems'
require 'json'
require 'net/http'

@green = 76_561_198_000_976_107
@laggy = 76_561_197_970_651_383
@steam_key = ENV.fetch('STEAM_API_KEY', nil)

def pull_json(url)
  json = Net::HTTP.get(URI.parse(url))
  JSON.parse(json)
end

def pull_owned_games(person)
  url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/
         v0001/?key=#{@steam_key}&steamid=#{person}&format=json"
  pull_json(url)
end

def pull_app_list
  url = 'http://api.steampowered.com/ISteamApps/GetAppList/v0001/'
  pull_json(url)
end

# get id to name map
app_hash = {}
app_list = pull_app_list
app_list['applist']['apps']['app'].each do |a|
  app_hash[a['appid']] = a['name']
end

# get green's games
green_games_raw = pull_owned_games(@green)['response']['games']
green_games = []
green_games_raw.each do |g|
  green_games << g['appid']
end

# get laggy's games
laggy_games_raw = pull_owned_games(@laggy)['response']['games']
laggy_games = []
laggy_games_raw.each do |g|
  laggy_games << g['appid']
end

# get the intersection
shared_games_ids = green_games & laggy_games
shared_games = []
shared_games_ids.each do |g|
  next if app_hash[g].nil?

  shared_games << app_hash[g]
end
shared_games.sort!

# spit them out to screen
shared_games.each do |g|
  puts g
end

puts shared_games.length
