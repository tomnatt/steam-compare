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


    get '/' do
        title = "Who is playing?"
        haml :index, :format => :html5, :locals => {:title => title, :users => users}
    end

    get '/compare' do

        u = params["u"].split(",")

        # get the intersection of the games list and convert to proper names
        # todo make this more intelligent, and power from the parameter
        sharedGamesIds = (users["green"].games & users["laggy"].games) & users["twosid"].games & users["jimmy"].games 
        sharedGames = Array.new
        sharedGamesIds.each do |g|
            sharedGames << appHash[g]
        end
        sharedGames.sort!

        # todo put this into the template
        puts sharedGames.length

        title = "What to play?"
        haml :compare, :format => :html5, :locals => {:title => title, :games => sharedGames}
    end

end
