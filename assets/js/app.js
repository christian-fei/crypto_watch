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
const $orderbook = document.querySelector('.orderbook')
const $ticker = document.querySelector('.ticker')
const svg = d3.select('.orderbook-graph svg')

let matchesChannel = socket.channel("data:matches", {})
matchesChannel.join()
  .receive("ok", resp => { console.log("matches channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join matches channel", resp) })
let level2Channel = socket.channel("data:level2", {})
level2Channel.join()
  .receive("ok", resp => { console.log("level2 channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join level2 channel", resp) })
let orderbookChannel = socket.channel("data:order_book", {})
orderbookChannel.join()
  .receive("ok", resp => { console.log("order_book channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join order_book channel", resp) })

orderbookChannel.on("data", (message) => {
  const { data: orderbook } = message

  const spread = orderbook.asks[0][0] - orderbook.bids[0][0]
  const asks = orderbook.asks.slice(0, 10).reverse()
  const bids = orderbook.bids.slice(0, 10)

  // {type, price, total}
  let minAskPrice = Math.min(...orderbook.asks.map(a => +a[0]))
  let maxBidPrice = Math.max(...orderbook.bids.map(a => +a[0]))
  console.log({
    minAskPrice
    , maxBidPrice
  })
  let sumAsk = 0
  let sumBid = 0
  const orderbookGraphData = orderbook.asks.filter(a => +a[0] < minAskPrice + 1000) //.slice(0, 50)
    .map(a => ({ type: 'ask', price: +a[0], total: sumAsk += +a[1] }))
    .concat(
      orderbook.bids.filter(a => +a[0] > maxBidPrice - 1000) //.slice(0, 50)
        .map(a => ({ type: 'bid', price: +a[0], total: sumBid += +a[1] }))
    )

  draw(orderbookGraphData, svg)

  const maxSize = Math.max(...asks.map(o => o[1]).concat(bids.map(o => o[1])))
  const calcPercentage = size => size / maxSize * 100

  $orderbook.innerHTML = `
    ${asks.map(o => `<div class="orderbook-item orderbook-buy">${o[1]} ${o[0]}<div class="bg-size" style="width: ${calcPercentage(o[1]) / 10}%"></div></div>`).join('')}
    <div class="orderbook-spread">Spread ${spread.toFixed(2)}</div>
    ${bids.map(o => `<div class="orderbook-item orderbook-sell">${o[1]} ${o[0]}<div class="bg-size" style="width: ${calcPercentage(o[1]) / 10}%"></div></div>`).join('')}
  `
})
level2Channel.on("data", (message) => {
  const { data } = message
  if (Array.isArray(data)) debugger

  const $level2 = document.createElement('div')
  $level2.innerHTML = `
    <div class="level2-item ${data.changes[0][0]}">${data.changes[0][0]} ${data.changes[0][1]} ${data.changes[0][2]} <div class="time">${data.time.substring(11)}</div></div>
  `
  $level2s.prepend($level2)

  if ($level2s.childNodes.length > 10) {
    const last = $level2s.childNodes[$level2s.childNodes.length - 1]
    last.parentNode.removeChild(last)
  }

})
matchesChannel.on("data", (message) => {
  const { data } = message

  if (Array.isArray(data)) {
    $ticker.innerHTML = `
    <h1 class="blink">${data[0].price}</h1>
  `

    return data.forEach(renderMatch)
  }
  if (!data.side) return

  renderMatch(data)
  $ticker.innerHTML = `
    <h1 class="blink">${data.price}</h1>
  `

  function renderMatch(data) {
    const $match = document.createElement('div')
    $match.innerHTML = `
      <div class="flex"><div>${data.side}</div> <div>${data.size}</div> <div>${data.price}</div></div>
    `

    $match.classList.add(data.side)
    $match.classList.add('match')
    $matches.prepend($match)

    if ($matches.childNodes.length > MAX_VISIBLE_MATCHES) {
      const last = $matches.childNodes[$matches.childNodes.length - 1]
      last.parentNode.removeChild(last)
    }
  }

})

function draw(unsortedData, target, d3 = window.d3) {
  d3.selectAll("svg > *").remove();

  const margin = { top: 20, right: 20, bottom: 30, left: 40 };
  const width = target.node().clientWidth - margin.left - margin.right;
  const height = target.node().clientHeight - margin.top - margin.bottom;
  const x = d3.scaleLinear().range([0, width]);
  const y = d3.scaleLinear().range([height, 0]);

  const g = target.append('g')
    .attr('transform', `translate(${margin.left},${margin.top})`);

  const data = unsortedData.sort((a, b) => (a.price > b.price ? 1 : -1));

  x.domain([
    d3.min(data, d => d.price),
    d3.max(data, d => d.price) + 1,
  ]);
  y.domain([0, d3.max(data, d => d.total)]);

  g.append('g')
    .attr('class', 'axis axis--x')
    .attr('transform', `translate(0,${height})`)
    .call(d3.axisBottom(x));

  g.append('g')
    .attr('class', 'axis axis--y')
    .call(d3.axisLeft(y));

  // // Define the div for the tooltip
  // const tooltip = d3.select('body').append('div')
  //   .attr('class', 'orderbook-visualisation-tooltip')
  //   .style('position', 'absolute')
  //   .style('top', `${target.node().parentNode.offsetTop}px`)
  //   .style('left', `${(target.node().parentNode.offsetLeft + margin.left + (width / 2)) - 100}px`)
  //   .style('width', '200px')
  //   .style('opacity', 0)
  //   .html('');

  g.selectAll('.bar')
    .data(data)
    .enter().append('rect')
    .attr('class', d => `bar ${d.type}`)
    .attr('x', d => x(d.price))
    .attr('y', d => y(d.total))
    .attr('width', (d, i) => {
      // is there a next element and do they have the same type:
      // fill until the next order
      if (data[i + 1] && data[i + 1].type === d.type) {
        return x(data[i + 1].price) - x(d.price);
        // is there a next element and they don't have the same type:
        // market price valley
      } else if (data[i + 1]) {
        return (x.range()[1] - x.range()[0]) / data.length;
      }
      // this is the last element: fill until the end of the graph
      return x.range()[1] - x(d.price);
    })
    .attr('height', d => height - y(d.total))
  // .on('mouseover', (d) => {
  //   tooltip.transition()
  //     .duration(500)
  //     .style('opacity', 1);

  //   let html = '<table>';

  //   Object.keys(d).forEach((key) => {
  //     html += `<tr><td><b>${key}</b></td><td>${d[key]}</td></tr>`;
  //   });

  //   html += '</table>';

  //   tooltip.html(html);
  // })
  // .on('mouseout', () =>
  //   tooltip.transition().duration(500).style('opacity', 0),
  // );
};

