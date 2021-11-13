defmodule CryptoWatch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CryptoWatchWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, [name: CryptoWatch.PubSub, adapter: Phoenix.PubSub.PG2]},
      {CryptoWatch.CoinbasePro.WebsocketClient, ["BTC-EUR"]},
      CryptoWatch.OrderBook,
      CryptoWatch.Cache,
      # Start the Endpoint (http/https)
      CryptoWatchWeb.Endpoint
      # Start a worker by calling: CryptoWatch.Worker.start_link(arg)
      # {CryptoWatch.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CryptoWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoWatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
