defmodule CryptoWatchWeb.DataChannel do
  use CryptoWatchWeb, :channel

  @impl true
  def join("data:matches", _payload, socket) do
    {:ok, socket}
  end

  def join("data:level2", _payload, socket) do
    {:ok, socket}
  end

  def broadcast_match(data) do
    Phoenix.PubSub.broadcast(
      CryptoWatch.PubSub,
      "data:matches",
      %{match: data}
    )
  end

  def broadcast_level2(data) do
    Phoenix.PubSub.broadcast(
      CryptoWatch.PubSub,
      "data:level2",
      %{level2: data}
    )
  end

  @impl true

  def handle_info(%{match: data}, socket) do
    push(socket, "data", %{data: data})
    {:noreply, socket}
  end

  def handle_info(%{level2: data}, socket) do
    push(socket, "data", %{data: data})
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