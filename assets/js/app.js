import "../css/app.css"
import "phoenix_html"
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'

let liveSocket = new LiveSocket('/live', Socket, {
  params: {
    productId: 'BTC-EUR',
  },
})
liveSocket.connect()
