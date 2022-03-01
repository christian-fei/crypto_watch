defmodule CryptoWatchWeb.CryptoLive.Index do
  use Phoenix.LiveView
  # use CryptoWatchWeb, :live_view


  @impl true
  def mount(_params, _session, socket) do
    product_id = "BTC-EUR"
    if connected?(socket), do: Process.send_after(self(), :tick, 500)

    {:ok,
     socket
     |> assign(:product_id, product_id)
     |> assign(:matches, matches(product_id))
     |> assign(:orderbook, orderbook(product_id))}
  end

  @impl true
  def handle_params(%{} = params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 500)

    {:noreply,
     socket
     |> assign(:matches, matches("BTC-EUR"))
     |> assign(:orderbook, orderbook("BTC-EUR"))}
  end

  defp matches(product_id) do
    case GenServer.call(CryptoWatch.Cache, {:get_matches, product_id}) do
      {:ok, matches} ->
        matches

      :error ->
        []
    end
  end

  defp orderbook(product_id) do
    case GenServer.call(CryptoWatch.Cache, {:get_order_book, product_id}) do
      :error ->
        %{"asks" => [], "bids" => []}
      order_book ->
        order_book
    end
  end
end
