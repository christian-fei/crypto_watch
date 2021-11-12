defmodule CryptoWatchElixirWeb.DataChannel do
  use CryptoWatchElixirWeb, :channel

  @impl true
  def join("data:matches", _payload, socket) do
    {:ok, socket}
  end

  def send_to_channel(data) do
    Phoenix.PubSub.broadcast(
      CryptoWatchElixir.PubSub,
      "data:matches",
      %{data: data}
    )
  end

  @impl true

  def handle_info(%{data: data}, socket) do
    push(socket, "match", %{data: data})
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
