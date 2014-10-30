
WebSocket = require('ws')
winston = require('winston')

winston.remove(winston.transports.Console)
winston.add(winston.transports.Console, { timestamp: ( -> new Date() ) })
console.log = winston.info

houmioServer = process.env.HORSELIGHTS_SERVER || "ws://localhost:3000"
houmioSitekey = process.env.HORSELIGHTS_SITEKEY || "devsite"

console.log "Using HOUMIO_SERVER=#{houmioServer}"
console.log "Using HOUMIO_SITEKEY=#{houmioSitekey}"

#Here, give the id of the data vendor
VENDOR = "nexa"

#General data types
LIGHT = "light"
#TODO:
#BUTTON = "button"
#SENSOR = "sensor"

lightData = {
	type: LIGHT,
	devaddr: "12341234",
	on: true,
	bri: 255,
	vendor: VENDOR
}

exit = (msg) ->
  console.log msg
  process.exit 1

socket = null
pingId = null

onSocketOpen = ->
  console.log "Connected to #{houmioServer}"
  pingId = setInterval ( -> socket.ping(null, {}, false) ), 3000
  publish = JSON.stringify { command: "publish", data: { sitekey: houmioSitekey, vendor: VENDOR } }
  socket.send(publish)
  console.log "Sent message:", publish

onSocketClose = ->
  clearInterval pingId
  exit "Disconnected from #{houmioServer}"

onSocketMessage = (s) ->
  console.log "Received message:", s

transmitToServer = (data) ->
	socket.send JSON.stringify { command: "generaldata", data: data }

socketPong = () ->
	socket.pong()

socket = new WebSocket(houmioServer)
socket.on 'open', onSocketOpen
socket.on 'close', onSocketClose
socket.on 'error', exit
socket.on 'ping', socketPong
socket.on 'message', onSocketMessage