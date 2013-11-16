#!/bin/ruby

require 'rubygems'
require 'haml'
require 'sinatra'

require './steam_user.rb'

class MyApp < Sinatra::Base

    # load config file - to do, load the below from a file

    # create users
    users = Hash.new
    users["green"] = SteamUser.new("Green", 76561198000976107)
    users["laggy"] = SteamUser.new("Laggy", 76561197970651383)
    users["wheels"] = SteamUser.new("Wheels", 76561198001124293)
    users["twosid"] = SteamUser.new("Twosid", 76561197977955065)
    users["jimmy"] = SteamUser.new("Jimmy", 76561197999187925)

    # load the appid to name data
    url = "http://api.steampowered.com/ISteamApps/GetAppList/v0001/"
    appList = JSON.parse(Net::HTTP.get(URI.parse(url)))

    appHash = Hash.new
    appList["applist"]["apps"]["app"].each do |a|
        appHash[a["appid"]] = a["name"]
    end

    # routing
    get '/' do
        title = "Who is playing?"
        haml :index, :format => :html5, :locals => {:title => title, :users => users}
    end

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
