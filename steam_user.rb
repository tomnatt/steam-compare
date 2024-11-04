require 'json'
require 'net/http'

class SteamUser
  attr_reader :id, :name, :games_time, :games

  def initialize(name, id)
    @id = id
    @name = name
    @games_time = owned_games
    @games = games_list
  end

  private

  def owned_games
    # get the JSON list of the user's games
    steam_key = ENV.fetch('STEAM_API_KEY', nil)
    url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{steam_key}&steamid=#{@id}&format=json"
    json = Net::HTTP.get(URI.parse(url))
    JSON.parse(json)['response']['games']
  end

  def games_list
    @games_time.map { |g| g['appid'] }
  end
end
