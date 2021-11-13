defmodule CryptoWatch.CoinbasePro.ApiClient do
  def get_order_book(product_id \\ "BTC-EUR") do
    url = "https://api.pro.coinbase.com/products/" <> product_id <> "/book?level=2"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Poison.decode!()}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
