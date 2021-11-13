defmodule CryptoWatch.OrderBook do
  use GenServer
  @loop_interval 3_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_) do
    loop("BTC-EUR")
    {:ok, %{}}
  end

  def loop(product_id \\ "BTC-EUR") do
    Process.send_after(self(), %{get_order_book: product_id}, @loop_interval)
  end

  @impl true
  def handle_info(%{get_order_book: product_id}, order_books) do
    order_books =
      case CryptoWatch.CoinbasePro.ApiClient.get_order_book(product_id) do
        {:ok, order_book} ->
          Map.put(order_books, product_id, order_book)
          CryptoWatchWeb.DataChannel.broadcast_order_book(order_book)
          GenServer.cast(CryptoWatch.Cache, {:update_order_book, product_id, order_book})
          order_books

        {:error, reason} ->
          IO.puts("Error getting order book")
          IO.inspect(reason)
          order_books
      end

    loop(product_id)
    {:noreply, order_books}
  end

  @impl true
  def handle_call({:get, name}, _from, order_books) do
    {:reply, Map.fetch(order_books, name), order_books}
  end
end
