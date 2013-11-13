require 'json'
require 'net/http'

class SteamUser

    attr_reader :id, :name, :games

    def initialize(name, id)
        @id = id
        @name = name
        @games = getOwnedGames
    end

    private
        def getOwnedGames

            # get the JSON list of the user's games
            steam_key = ENV['STEAM_API_KEY']
            url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{steam_key}&steamid=#{@id}&format=json"
            json = Net::HTTP.get(URI.parse(url))
            gamesRaw = JSON.parse(json)["response"]["games"]

            # put the games in a useful list
            games = Array.new
            gamesRaw.each do |g|
                games << g["appid"]
            end

            return games

        end


end