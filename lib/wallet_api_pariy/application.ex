defmodule WalletApiPariy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WalletApiPariyWeb.Telemetry,
      WalletApiPariy.Repo,
      {DNSCluster, query: Application.get_env(:wallet_api_pariy, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WalletApiPariy.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WalletApiPariy.Finch},
      # Start a worker by calling: WalletApiPariy.Worker.start_link(arg)
      # {WalletApiPariy.Worker, arg},
      # Start to serve requests, typically the last entry
      WalletApiPariyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WalletApiPariy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WalletApiPariyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
