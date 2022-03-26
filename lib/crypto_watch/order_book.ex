defmodule CryptoWatch.OrderBook do
  use GenServer
  @delay 200

  def start_link(products \\ ["BTC-EUR"]) do
    GenServer.start_link(__MODULE__, products)
  end

  @impl GenServer
  def init(products \\ ["BTC-EUR"]) do
    loop(products)
    {:ok, %{}}
  end

  def loop(products \\ ["BTC-EUR"]) do
    products
    |> Enum.map(&send(self(), %{get_order_book: &1}))
  end

  @impl true
  def handle_info(%{get_order_book: product_id}, order_books) do
    order_books =
      case CryptoWatch.CoinbasePro.ApiClient.get_order_book(product_id) do
        {:ok, order_book} ->
          Map.put(order_books, product_id, order_book)
          GenServer.cast(CryptoWatch.Cache, {:update_order_book, product_id, order_book})
          Phoenix.PubSub.broadcast(CryptoWatch.PubSub, "orderbook-#{product_id}", %{orderbook: order_book})
          order_books

        {:error, reason} ->
          IO.puts("Error getting order book")
          IO.inspect(reason)
          order_books
      end
    :timer.sleep(@delay)
    loop([product_id])
    {:noreply, order_books}
  end

  @impl true
  def handle_call({:get, name}, _from, order_books) do
    {:reply, Map.fetch(order_books, name), order_books}
  end
end
