defmodule CryptoWatchWeb.CryptoLive.Index do
  use Phoenix.LiveView
  # use CryptoWatchWeb, :live_view


  @impl true
  def mount(_params, _session, socket) do
    product_id = "BTC-EUR"
    if connected?(socket) do
      Phoenix.PubSub.subscribe(CryptoWatch.PubSub, "orderbook-#{product_id}")
      Phoenix.PubSub.subscribe(CryptoWatch.PubSub, "matches-#{product_id}")
      Phoenix.PubSub.subscribe(CryptoWatch.PubSub, "level2-#{product_id}")
    end

    {:ok,
     socket
     |> assign(:product_id, product_id)
     |> assign(:matches, [])
     |> assign(:level2, [])
     |> assign(:orderbook, %{"asks" => [], "bids" => []})}
  end

  @impl true
  def handle_params(%{} = _params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{orderbook: orderbook}, socket) do
    {:noreply,
     socket
     |> assign(:orderbook, orderbook)}
  end
  @impl true
  def handle_info(%{match: match}, socket) do
    {:noreply,
     socket
     |> update(:matches, fn matches -> matches ++ [match] end)}
  end
  @impl true
  def handle_info(%{level2: level2}, socket) do
    {:noreply,
     socket
     |> update(:level2, fn l2 -> [level2] ++ l2 |> Enum.slice(0..50) end)}
  end
end