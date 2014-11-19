chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'
Robot = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

expect = chai.expect

describe 'event-announcer', ->

  adapter = null
  robot = null
  user = null

  beforeEach (done) ->

    robot = new Robot(null, 'mock-adapter', false, 'Hubot')

    robot.adapter.on 'connected', ->
      (require '../src/event-announcer')(@robot)

      user = robot.brain.userForId('1', name: 'test', room: "#test")
      adapter = robot.adapter

      done()

    robot.run()


  afterEach ->
    robot.shutdown()

  it '"sub foo" subscribes user to foo', (done) ->

    adapter.on "send", (envelope, strings) ->
      expect(strings[0]).match /subscribed #test to foo/
      done()

    adapter.receive new TextMessage(user, "Hubot sub foo")

  it '"show my subs" show subscribers subscriptions', (done) ->

    adapter.receive new TextMessage(user, "Hubot sub foo")

    adapter.on "send", (envelope, strings) ->
      expect(strings[0]).match /#test is listening to: foo/
      done()

    adapter.receive new TextMessage(user, "Hubot show my subs")

  it 'when subscribed, an event will be sent to subscribers', (done) ->

    adapter.receive new TextMessage(user, "Hubot sub foo")

    adapter.on "send", (envelope, strings) ->
      expect(strings[0]).match /fooEvent/
      done()

    robot.emit "ea-event", { name: "foo", message: "fooEvent" }

  it "when subscribed to '*', all events will be listened to.", (done) ->

    adapter.receive new TextMessage(user, "Hubot sub foo")

    adapter.on "send", (envelope, strings) ->
      expect(strings[0]).match /fooEvent/
      done()

    robot.emit "ea-event", { name: "foo", message: "fooEvent" }

  it "when subscribed to 'foo*bar', will match a glob.", (done) ->

    adapter.receive new TextMessage(user, "Hubot sub foo")

    adapter.on "send", (envelope, strings) ->
      expect(strings[0]).match /fooEvent/
      done()

    robot.emit "ea-event", { name: "foo-rand-bar", message: "fooEvent" }

  it 'unsubscribers should report an unsubscription', (done) ->

    adapter.receive new TextMessage(user, "Hubot sub foo")

    adapter.on "send", (envelope, strings) ->
      expect(strings[0]).match /unsubscribed #test from foo/
      done()

    adapter.receive new TextMessage(user, "Hubot unsub foo")

  it 'unsubscribers should not show in my subs', (done) ->

    adapter.receive new TextMessage(user, "Hubot sub foo")
    adapter.receive new TextMessage(user, "Hubot unsub foo")

    adapter.on "send", (envelope, strings) ->
      expect(strings[0]).match /no subs for #test/
      done()

    adapter.receive new TextMessage(user, "Hubot show my subs")
