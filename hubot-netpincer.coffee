#
# hubot menü - shows what's for lunch in nearby restaurants
#


netpincer_menu = require('netpincer-napimenu')

module.exports = (robot) ->
  lat = process.env.HUBOT_NETPINCER_LAT or 47.5034905 
  lng = process.env.HUBOT_NETPINCER_LNG or 19.0621781
  radiusz = process.env.HUBOT_NETPINCER_RADIUS or 2
  robot.respond /menü/i, (msg) ->
    netpincer_menu (results) -> 
      if results
        results.forEach (result) ->
          if result
            msg.send "#{result.restaurant} (#{result.address})"
            result.menus.forEach (menu) ->
              msg.send menu
            msg.send("----")
      else
        msg.send "no result from netpincér :("
    , lat, lng, radiusz
