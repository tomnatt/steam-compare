steam-compare
=============

Compare games on friends' steam lists.

Written in ruby using Sinatra, HAML and HTML Kickstart.

Usage
-----

You'll need a [Steam API](http://steamcommunity.com/dev) key set as STEAM_API_KEY environment variable.

If you're using heroku, set it [like this](https://devcenter.heroku.com/articles/config-vars#setting-up-config-vars-for-a-deployed-application).

Put your group and their Steam ids into `config.json`

Setup:  
```sh
gem install bundler
bundle install
```

Go!  
```sh
rackup
```

Behold:  
[http://localhost:9292/](http://localhost:9292/)
