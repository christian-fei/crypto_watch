import "../css/app.css"
import "phoenix_html"
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import socket from "./data_socket.js"
const state = {
  level2enabled: window.localStorage.getItem('level2enabled') === 'true',
  productId: 'BTC-EUR'
}
let liveSocket = new LiveSocket('/live', Socket, {
  params: {
    productId: 'BTC-EUR',
  }
})
liveSocket.connect()


const $orderbook = document.querySelector('.orderbook')
const svg = d3.select('.orderbook-graph svg')

let orderbookChannel = socket.channel("data:order_book", {})
orderbookChannel.join()
  .receive("ok", resp => { console.log("order_book channel joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join order_book channel", resp) })

orderbookChannel.on("data", (message) => {
  console.log('orderbook data', message)
  const { order_book: orderbook, product_id } = message
  if (product_id !== state.productId) return
  
  // [type, price, total]
  let minAskPrice = Math.min(...orderbook.asks.map(a => +a[0]))
  let maxBidPrice = Math.max(...orderbook.bids.map(a => +a[0]))
  let sumAsk = 0
  let sumBid = 0
  const orderbookGraphData = orderbook.asks.filter(a => +a[0] < minAskPrice + 1000) //.slice(0, 50)
    .map(a => ({ type: 'ask', price: +a[0], total: sumAsk += +a[1] }))
    .concat(
      orderbook.bids.filter(a => +a[0] > maxBidPrice - 1000) //.slice(0, 50)
        .map(a => ({ type: 'bid', price: +a[0], total: sumBid += +a[1] }))
    )

  draw(orderbookGraphData, svg)
})


//https://gist.github.com/flavioespinoza/e7b086abf3f28ee05967d205f850b6af
function draw(unsortedData, target, d3 = window.d3) {
  console.log('draw')
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

