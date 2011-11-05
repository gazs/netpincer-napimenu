#!/usr/bin/env coffee
napimenu = require '../napimenu'
OptParse   = require 'optparse'

switches = [
  ["-l", "--latlng NUMBER", "lat, lng"],
  ["-r", "--radius NUMBER", "radius"]  
]


parser = new OptParse.OptionParser(switches)
options = {}

parser.on "radius", (opt, value) ->
  options.radius = value
parser.on "latlng", (opt, value) ->
  [options.latitude, options.longitude] = value.split(",")

parser.parse process.ARGV


if options.latitude and options.longitude and options.radius
  console.log "f"
  napimenu(console.log, options.latitude, options.longitude, options.radius)


process.on 'SIGTERM', -> process.exit(0)

