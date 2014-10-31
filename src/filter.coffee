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
#   hubot hello - "hello!"
#   hubot orly - "yarly"
#
# Author:
#   tombell

module.exports = (robot) ->

  getSubscription = () ->
    robot.brain.data.subscriptions ||= {}

  pushSubscription = (listener, eventMatch) ->
    subs = getSubscription
    subs[listener] ||= []
    subs[listener].push eventMatch
    robot.brain.save()

  publishEvent = (eventName, message) ->
    subs = getSubscription
    for listener, eventMatches of subs
      for eventMatch in eventMatches
        if eventName.lastIndexOf eventName != -1
          robot.send listener, message

  getListener = (msg) ->
    msg.message.user.reply_to || msg.message.user.room

  robot.respond /publish (\S+) (.*)/i, (msg)->
    eventName = msg.match[1]
    message = msg.match[2]
    publishEvent eventName, message

  robot.respond /sub (.*)/i, (msg) ->
    eventMatch = msg.match[1]
    listener = getListener msg
    pushSubscription listener, eventMatch
    msg.send "subscribed #{listener} to #{eventMatch}"

  robot.respond /show my subs/i, (msg) ->
    listener = getListener msg
    subs = getSubscription
    if listener of subs
      msg.send "#{listener} is listening to: #{subs[listener]}"
    else
      msg.send "No subs for #{listener}"
