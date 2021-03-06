defmodule CryptoWatchWeb.DataChannel do
  use CryptoWatchWeb, :channel

  # client api
  def broadcast_match(data, product_id) do
    Phoenix.PubSub.broadcast(
      CryptoWatch.PubSub,
      "data:matches",
      %{match: data, product_id: product_id}
    )
  end

  def broadcast_level2(data) do
    Phoenix.PubSub.broadcast(
      CryptoWatch.PubSub,
      "data:level2",
      %{level2: data}
    )
  end

  def broadcast_order_book(data, product_id) do
    Phoenix.PubSub.broadcast(
      CryptoWatch.PubSub,
      "data:order_book",
      %{order_book: data, product_id: product_id}
    )
  end

  # server api
  @impl true
  def join("data:matches", _payload, socket) do
    send(self(), {:after_join_matches, "BTC-EUR"})
    {:ok, socket}
  end

  @impl true
  def join("data:level2", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def join("data:order_book", _payload, socket) do
    send(self(), {:after_join_order_book, "BTC-EUR"})
    {:ok, socket}
  end

  def handle_info({:after_join_order_book, product_id}, socket) do
    case GenServer.call(CryptoWatch.Cache, {:get_order_book, product_id}) do
      {:ok, order_book} ->
        push(socket, "data", %{order_book: order_book, product_id: product_id})

      :error ->
        IO.puts("error getting order book " <> product_id)
    end

    {:noreply, socket}
  end

  def handle_info({:after_join_matches, product_id}, socket) do
    case GenServer.call(CryptoWatch.Cache, {:get_matches, product_id}) do
      {:ok, matches} ->
        push(socket, "data", %{match: matches, product_id: product_id})

      :error ->
        IO.puts("error getting matches " <> product_id)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{match: match, product_id: product_id}, socket) do
    push(socket, "data", %{match: match, product_id: product_id})
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{level2: data}, socket) do
    push(socket, "data", %{data: data})
    {:noreply, socket}
  end

  def handle_info(%{order_book: order_book, product_id: product_id}, socket) do
    push(socket, "data", %{order_book: order_book, product_id: product_id})
    {:noreply, socket}
  end

  # # Channels can be used in a request/response fashion
  # # by sending replies to requests from the client
  # @impl true
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (data:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast(socket, "shout", payload)
  #   {:noreply, socket}
  # end
end
