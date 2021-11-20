defmodule CryptoWatchWeb.PageController do
  use CryptoWatchWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", pairs: ["BTC-EUR", "ETH-EUR", "LTC-EUR"])
  end
end
