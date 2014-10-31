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

  subscriptions = (ev, partial = false) ->
    subs = robot.brain.data.subcriptions ||= {}

  robot.respond /subscribe (.*)/i/, (msg) ->
    evMatch = msg.match[1]
    listener = msg.message.user.reply_to || msg.message.user.room
    msg.send "subscribed #{listener} to #{evMatch}"