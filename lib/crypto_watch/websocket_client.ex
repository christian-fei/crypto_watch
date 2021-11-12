defmodule CryptoWatch.WebsocketClient do
  use WebSockex

  @endpoint "wss://ws-feed.exchange.coinbase.com"

  def start_link(products \\ ["BTC-EUR"]) do
    {:ok, pid} = WebSockex.start_link(@endpoint, __MODULE__, :no_state)
    subscribe_matches(pid, products)
    subscribe_level2(pid, products)
    {:ok, pid}
  end

  @impl WebSockex
  def handle_connect(_conn, state) do
    IO.puts("Connected!")
    {:ok, state}
  end

  @impl WebSockex
  def handle_frame(_frame = {:text, msg}, state) do
    data =
      msg
      |> Jason.decode!(keys: :atoms)

    # |> IO.inspect()

    if data[:type] == "match", do: CryptoWatchWeb.DataChannel.broadcast_match(data)
    if data[:type] == "l2update", do: CryptoWatchWeb.DataChannel.broadcast_level2(data)

    {:ok, state}
  end

  @impl WebSockex
  def handle_disconnect(_conn, state) do
    IO.puts("disconnected")
    behaviour = if Mix.env() == :test, do: :ok, else: :reconnect
    {behaviour, state}
  end

  def subscribe_matches(pid, products \\ []) do
    subscription_msg =
      %{
        type: "subscribe",
        product_ids: products,
        channels: ["matches"]
      }
      |> Jason.encode!()

    WebSockex.send_frame(pid, {:text, subscription_msg})
  end

  def subscribe_level2(pid, products \\ []) do
    subscription_msg =
      %{
        type: "subscribe",
        product_ids: products,
        channels: ["level2"]
      }
      |> Jason.encode!()

    WebSockex.send_frame(pid, {:text, subscription_msg})
  end
end
