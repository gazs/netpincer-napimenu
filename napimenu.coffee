http = require 'http'
querystring = require 'querystring'

htmlparser = require 'htmlparser'
select = require('soupselect').select

Iconv = require('iconv').Iconv

iconv = new Iconv 'ISO-8859-2', 'UTF-8' 

lat = process.env.HUBOT_NETPINCER_LAT or 47.5034905 
lng = process.env.HUBOT_NETPINCER_LNG or 19.0621781
radiusz = process.env.HUBOT_NETPINCER_RADIUS or 2


@get_menu = (cb, params={lat, lng, radiusz, limit_offset:0, limit_max:10, etterem_neve:"", rendez:"tavolsag", page:"maps", out:"xml", type:"dailymenu"}) ->
  options =
    host: "www.netpincer.hu"
    port: 80
    path: "/index.php?#{querystring.stringify(params)}"

  http.get(options, (res) ->
    buffers = []
    length = 0
    str = ""

    res.on 'data', (chunk) ->
      # this will likely fail spectacularly with the first multibyte character that comes along, hello unicode snowman!
      # not to mention how inefficient this is
      str += iconv.convert(chunk) 
      ## we should use this instead: (problem: how to concat array of buffers?
      #buffers.push chunk
    res.on 'end', ->
      cb parse_netpincer(str)
    )

get_menu_from_dom = (dom) ->
  rows_with_junk = select(dom, "tr")
  rows_we_need = rows_with_junk.filter (row, index) ->
    return false if index is 0 # restaurant logos, unnecessary
    return true if row.children.length > 1 # instead of table border-styles, they use additional rows & cols :(
  full_menu = rows_we_need.map (row) ->
    columns = select(row, "td").filter (el, index, array) -> index % 2

    #restaurant_name_w_junk = columns[0]
    restaurant_name = select(row, "a.etterem_neve")[0].children[0].data
    todays_menu_w_junk = select(columns[1], "a")
    #tomorrows_menu_w_junk = select(columns[2], "a") # but we don't care about that

    menus = todays_menu_w_junk.map (line) ->
      output_line = ""
      line.children.forEach (child) ->
        if child.data == "b"
          output_line += "#{child.children[0].data}: "
        if child.data.length > 4
          output_line += child.data
      return output_line
    return {restaurant: restaurant_name, menus: menus}
  return (full_menu)

parse_netpincer = (body) ->
  what_were_looking_for = /<tablazat><!\[CDATA\[([\s\S]*?)\]\]><\/tablazat/
  try
    tablazat = body.match(what_were_looking_for)[1]
  catch e
    console.error "regex gebasz"
    return false
  handler = new htmlparser.DefaultHandler()
  parser = new htmlparser.Parser(handler)
  # we're synchronous already, so why bother pretending otherwise?
  parser.parseComplete tablazat
  return get_menu_from_dom(handler.dom)

