defmodule CryptoWatchElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CryptoWatchElixirWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CryptoWatchElixir.PubSub},
      # Start the Endpoint (http/https)
      CryptoWatchElixirWeb.Endpoint
      # Start a worker by calling: CryptoWatchElixir.Worker.start_link(arg)
      # {CryptoWatchElixir.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CryptoWatchElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoWatchElixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
