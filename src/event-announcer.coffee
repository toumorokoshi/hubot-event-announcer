# Description:
#   Say Hi to Hubot.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Hubot sub <event> - subscribe the room or user to an event with name <event> (an event matches as a substring or a glob)
#   Hubot unsub <event> - unsubscribe the room or user from an event
#   Hubot show my subs - show the subs for the current group or user
#   Hubot show all subs - show all subs hubot has registered
#
# Author:
#   tombell

minimatch = require('minimatch')

module.exports = (robot) ->

  getSubscription = () ->
    robot.brain.get('eventannouncer:subs') or {}

  pushSubscription = (listener, eventMatch) ->
    subs = getSubscription()
    subs[listener] ||= []
    subs[listener].push eventMatch
    robot.brain.set 'eventannouncer:subs', subs
    robot.brain.save()

  removeSubscription = (listener, eventMatch) ->
    subs = getSubscription()
    matches = subs[listener] || []
    eventIndex = matches.indexOf(eventMatch)
    if eventIndex > -1
      matches.splice(eventIndex)
    robot.brain.set 'eventannouncer:subs', subs
    robot.brain.save()

  publishEvent = (eventName, message) ->
    subs = getSubscription()
    for listener, eventMatches of subs
      for eventMatch in eventMatches
        if eventName.lastIndexOf(eventMatch) != -1 or minimatch(eventName, eventMatch)
          robot.send listener, "#{eventName}: #{message}"

  getListener = (msg) ->
    msg.message.user.reply_to || msg.message.user.room

  robot.on "ea-event", (event) ->
    publishEvent event.name, event.message

  robot.respond /pub (\S+) (.*)/i, (msg) ->
    eventName = msg.match[1]
    message = msg.match[2]
    publishEvent eventName, message

  robot.respond /sub (.*)/i, (msg) ->
    eventMatch = msg.match[1]
    listener = getListener msg
    pushSubscription listener, eventMatch
    msg.send "subscribed #{listener} to #{eventMatch}"

  robot.respond /unsub (.*)/i, (msg) ->
    eventMatch = msg.match[1]
    listener = getListener msg
    removeSubscription listener, eventMatch
    msg.send "unsubscribed #{listener} from #{eventMatch}"

  robot.respond /show my subs/i, (msg) ->
    listener = getListener msg
    subs = getSubscription()
    if listener of subs and subs[listener].length > 0
      msg.send "#{listener} is listening to: #{subs[listener]}"
    else
      msg.send "no subs for #{listener}"

  robot.respond /show all subs/i, (msg) ->
    for listener, eventMatches of getSubscription()
      msg.send "#{listener} is listening to: #{eventMatches}"
