defmodule CryptoWatch.CacheTest do
  use ExUnit.Case, async: true

  test "cache process is started" do
    assert CryptoWatch.Cache
           |> Process.whereis()
           |> Process.alive?()
  end

  test "caches match" do
    match = %{
      side: "buy",
      size: 0.024218,
      price: 53443.32443
    }

    GenServer.cast(CryptoWatch.Cache, {:add_match, "BTC-EUR", match})
    {:ok, matches} = GenServer.call(CryptoWatch.Cache, {:get_matches, "BTC-EUR"})

    assert matches == [match]
  end
end
