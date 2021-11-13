defmodule CryptoWatch.Cache do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(_) do
    Process.register(self(), __MODULE__)

    {:ok,
     %{
       order_books: %{},
       matches: %{}
     }}
  end

  @impl true
  def handle_call({:get_order_book, name}, _from, state) do
    {:reply, Map.fetch(state.order_books, name), state}
  end

  @impl true
  def handle_call({:get_matches, name}, _from, state) do
    {:reply, Map.fetch(state.matches, name), state}
  end

  @impl true
  def handle_cast({:update_order_book, name, order_book}, state) do
    state = Map.merge(state, %{order_books: Map.put(%{}, name, order_book)})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:update_matches, name, matches}, state) do
    state = Map.merge(state, %{matches: Map.put(%{}, name, matches)})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:add_match, name, match}, state) do
    # beware that the matches will grow over time right now, FIX ME!
    state =
      Map.merge(
        state,
        %{
          matches:
            Map.merge(
              state.matches,
              Map.put(%{}, name, Map.get(state.matches, name, []) ++ [match])
            )
        }
      )

    {:noreply, state}
  end
end
