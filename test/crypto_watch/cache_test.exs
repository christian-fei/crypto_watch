defmodule CryptoWatch.CacheTest do
  use ExUnit.Case, async: true

  test "cache process is started" do
    assert CryptoWatch.Cache
           |> Process.whereis()
           |> Process.alive?()
  end

  test "add match and get cached matches" do
    match = %{
      side: "buy",
      size: 0.024218,
      price: 53443.32443
    }

    GenServer.cast(CryptoWatch.Cache, {:add_match, "BTC-EUR", match})
    {:ok, matches} = GenServer.call(CryptoWatch.Cache, {:get_matches, "BTC-EUR"})

    assert matches == [match]
  end

  test "update orderbook and get cached orderbook" do
    orderbook = %{
      asks: [],
      bids: [],
      time: ""
    }

    GenServer.cast(CryptoWatch.Cache, {:update_order_book, "BTC-EUR", orderbook})
    {:ok, ^orderbook} = GenServer.call(CryptoWatch.Cache, {:get_order_book, "BTC-EUR"})
  end
end
