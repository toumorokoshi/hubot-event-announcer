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
  robot.respond /filter/, (msg) ->
    msg.reply "filter what?"

  robot.hear /pweez/, ->
    msg.send "no"
