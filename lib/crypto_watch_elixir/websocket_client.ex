defmodule CryptoWatchElixir.WebsocketClient do
  use WebSockex

  @endpoint "wss://ws-feed.exchange.coinbase.com"

  def start_link(products \\ ["BTC-EUR"]) do
    {:ok, pid} = WebSockex.start_link(@endpoint, __MODULE__, :no_state)
    subscribe_to(pid, products)
    {:ok, pid}
  end

  @impl WebSockex
  def handle_connect(_conn, state) do
    IO.puts("Connected!")
    {:ok, state}
  end

  @impl WebSockex
  def handle_frame(_frame = {:text, msg}, state) do
    msg
    |> Jason.decode!()
    |> IO.inspect()
    |> CryptoWatchElixirWeb.DataChannel.send_to_channel()

    {:ok, state}
  end

  @impl WebSockex
  def handle_disconnect(_conn, state) do
    IO.puts("disconnected")
    {:reconnect, state}
  end

  def subscribe_to(pid, products \\ []) do
    subscription_msg =
      %{
        type: "subscribe",
        product_ids: products,
        channels: ["matches"]
      }
      |> Jason.encode!()

    WebSockex.send_frame(pid, {:text, subscription_msg})
  end
end
