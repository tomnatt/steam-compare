require 'json'
require 'net/http'

class SteamUser

    attr_reader :id, :name, :games_time, :games

    def initialize(name, id)
        @id = id
        @name = name
        @games_time = getOwnedGames
        @games = getGamesList
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
                games << g
            end

            return games

        end

        def getGamesList

            # create a list of just the games ids
            games = Array.new
            @games_time.each do |g|
                games << g["appid"]
            end

            return games

        end


end