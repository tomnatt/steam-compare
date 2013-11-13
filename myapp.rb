#!/bin/ruby

require 'rubygems'
require 'haml'
require 'sinatra'

require './steam_user.rb'

class MyApp < Sinatra::Base

    # load config file - to do

    # create users
    users = Hash.new
    users["green"] = SteamUser.new("Green", 76561198000976107)
    users["laggy"] = SteamUser.new("Laggy", 76561197970651383)

    get '/' do
        title = "What to play?"
        haml :index, :format => :html5, :locals => {:title => title, :users => users}
    end

end
