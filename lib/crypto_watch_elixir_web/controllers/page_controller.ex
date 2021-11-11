defmodule CryptoWatchElixirWeb.PageController do
  use CryptoWatchElixirWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
