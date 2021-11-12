defmodule CryptoWatchElixir.WebsocketClient do
  use WebSockex

  @endpoint "wss://ws-feed.exchange.coinbase.com"

  def start_link(state) do
    WebSockex.start_link(@endpoint, __MODULE__, state)
  end

  @impl true
  def handle_connect(_conn, state) do
    IO.puts("Connected!")
    {:ok, state}
  end

  @impl true
  def handle_frame(_frame = {:text, msg}, state) do
    msg
    |> Jason.decode!()
    |> IO.inspect()

    {:ok, state}
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
