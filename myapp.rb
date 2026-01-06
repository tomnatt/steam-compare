#!/bin/ruby

require 'rubygems'
require 'haml'
require 'sinatra'

require './steam_user'
require './steamdb/database_access'

class MyApp < Sinatra::Base
  # load config file
  config = JSON.parse(File.read('config.json'))
  config['users'].sort! { |a, b| a['name'] <=> b['name'] }

  # create users
  users = {}
  config['users'].each do |u|
    users[u['name'].downcase] = SteamUser.new(u['name'], u['id'])
    sleep 1 # Initializer above hits the Steam API so avoid hammering it
  end

  steam_store = DatabaseAccess.new

  # routing
  get '/' do
    title = 'Who is playing?'
    haml :index, format: :html5, locals: { title: title, users: users }
  end

  # compare the games lists of the specified users
  get '/compare' do
    # get the intersection of the games
    shared_games_ids = []
    params.each do |key, value|
      # use the param if it's user0, etc
      next unless key =~ /user\d+/

      shared_games_ids = intersect_lists(shared_games_ids, users[value].games)
    end

    # convert the games id list to game names
    shared_games = []
    shared_games_ids.each do |game_id|
      next if steam_store.get_name_from_id(game_id).nil?

      shared_games << steam_store.get_name_from_id(game_id)
    end
    shared_games.sort!

    title = 'What to play?'
    haml :compare, format: :html5, locals: { title: title, games: shared_games }
  end

  # show a user's top games based on playtime
  get '/favourites' do
    u = users[params['user']]
    all_games = u.games_time

    # sort by time (most first)
    all_games.sort! { |a, b| b['playtime_forever'] <=> a['playtime_forever'] }

    # get the first 10 to pass to template
    games = all_games[0..9]

    # add the game name and time (in hours)
    games.each do |g|
      g['name'] = steam_store.get_name_from_id(g['appid'])
      g['time_played'] = g['playtime_forever'] / 60
    end

    title = 'I played this'
    haml :favourites, format: :html5, locals: { title: title, user: u, games: games }
  end

  private

  def intersect_lists(list1, list2)
    # return list2 if list1 is empty
    return list1 & list2 unless list1.empty?

    list2
  end
end
