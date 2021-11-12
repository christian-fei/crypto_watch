// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
// import {Socket} from "phoenix"
// import {LiveSocket} from "phoenix_live_view"
// import topbar from "../vendor/topbar"

// let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
// let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
// topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
// window.addEventListener("phx:page-loading-start", info => topbar.show())
// window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
// liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
// window.liveSocket = liveSocket

import socket from "./data_socket.js"

const MAX_VISIBLE_MATCHES = 20
const $matches = document.querySelector('.matches')
const $level2s = document.querySelector('.level2')

let matchesChannel = socket.channel("data:matches", {})
matchesChannel.join()
  .receive("ok", resp => { console.log("matches channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join matches channel", resp) })
let level2Channel = socket.channel("data:level2", {})
level2Channel.join()
  .receive("ok", resp => { console.log("level2 channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join level2 channel", resp) })

level2Channel.on("data", (message) => {
  // console.log('level2', message.data)
  const { data } = message
  const $level2 = document.createElement('div')
  $level2.innerHTML = `
    <div>${data.changes[0][0]} ${data.changes[0][1]} ${data.changes[0][2]}</div> <div>${data.time}</div>
  `
  $level2s.prepend($level2)

  if ($level2s.childNodes.length > 10) {
    const last = $level2s.childNodes[$level2s.childNodes.length - 1]
    last.parentNode.removeChild(last)
  }

})
matchesChannel.on("data", (message) => {
  // console.log('match', message.data)

  const { data } = message
  const $match = document.createElement('div')
  $match.innerHTML = `
    <div>${data.side}</div> <div>${data.size}</div> <div>${data.price}</div>
  `

  $match.classList.add(data.side)
  $match.classList.add('match')
  $matches.prepend($match)

  if ($matches.childNodes.length > MAX_VISIBLE_MATCHES) {
    const last = $matches.childNodes[$matches.childNodes.length - 1]
    last.parentNode.removeChild(last)
  }
})