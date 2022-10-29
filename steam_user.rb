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
    games_raw = JSON.parse(json)['response']['games']

    # put the games in a useful list
    games = []
    games_raw.each do |g|
      games << g
    end

    games
  end

  def games_list
    # create a list of just the games ids
    games = []
    @games_time.each do |g|
      games << g['appid']
    end

    games
  end
end
