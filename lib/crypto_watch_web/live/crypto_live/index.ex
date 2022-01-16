defmodule CryptoWatchWeb.CryptoLive.Index do
  use CryptoWatchWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    product_id = "BTC-EUR"

    {:ok, assign(socket, :matches, matches(product_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.inspect(params ,label: "handle params")
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, state, params) do
    socket
    # |> assign(:page_title, "Edit Crypto")
  end


  defp matches(product_id) do
    case GenServer.call(CryptoWatch.Cache, {:get_matches, product_id}) do
      {:ok, matches} ->
        matches

      :error ->
        []
    end
  end
end
