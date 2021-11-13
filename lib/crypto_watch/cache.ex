defmodule CryptoWatch.Cache do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    Process.register(self(), __MODULE__)

    {:ok,
     %{
       order_books: %{}
     }}
  end

  @impl true
  def handle_call({:get_order_book, name}, _from, state) do
    {:reply, Map.fetch(state[:order_books], name), state}
  end

  @impl true
  def handle_cast({:update_order_book, name, order_book}, state) do
    state = Map.merge(state, %{order_books: Map.put(%{}, name, order_book)})
    {:noreply, state}
  end
end
