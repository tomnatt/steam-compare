#!/bin/ruby

require 'rubygems'
require 'haml'
require 'sinatra'

require './steam_user.rb'

class MyApp < Sinatra::Base

    # load config file
    config = JSON.parse(File.read("config.json"))
    config["users"].sort! { |a, b|  a["name"] <=> b["name"] }

    # create users
    users = Hash.new
    config["users"].each do |u|
        users[u["name"].downcase] = SteamUser.new(u["name"], u["id"])
    end

    # load the appid to name data
    url = "http://api.steampowered.com/ISteamApps/GetAppList/v0001/"
    appList = JSON.parse(Net::HTTP.get(URI.parse(url)))

    # put the appid to name data in a useful format
    appHash = Hash.new
    appList["applist"]["apps"]["app"].each do |a|
        appHash[a["appid"]] = a["name"]
    end

    # routing
    get '/' do
        title = "Who is playing?"
        haml :index, :format => :html5, :locals => {:title => title, :users => users}
    end

    # compare the games lists of the specified users
    get '/compare' do

        # get the intersection of the games
        sharedGamesIds = Array.new
        params.each do |key, value|
            # use the param if it's user0, etc
            if key =~ /user\d+/ then
                sharedGamesIds = intersectLists(sharedGamesIds, users[value].games)
            end
        end

        # convert the games id list to game names
        sharedGames = Array.new
        sharedGamesIds.each do |g|
            sharedGames << appHash[g]
        end
        sharedGames.sort!

        title = "What to play?"
        haml :compare, :format => :html5, :locals => {:title => title, :games => sharedGames}
    end

    # show a user's top games based on playtime
    get '/favourites' do

        u = users[params['user']]
        all_games = u.games_time

        # sort by time (most first)
        all_games.sort! { |a, b|  b["playtime_forever"] <=> a["playtime_forever"] }

        # get the first 10 to pass to template
        games = all_games[0..9]

        # add the game name and time (in hours)
        games.each do |g|
            g["name"] = appHash[g["appid"]]
            g["time_played"] = g["playtime_forever"] / 60
        end

        title = "I played this"
        haml :favourites, :format => :html5, :locals => 
            {:title => title, :user => u, :games => games}

    end

    private

        def intersectLists(list1, list2)
            # return list2 if list1 is empty
            if list1.length > 0 then
                return list1 & list2
            else 
                return list2
            end
        end

end
