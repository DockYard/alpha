defmodule Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Server.Telemetry,
      {DNSCluster, query: Application.get_env(:<%= @otp_app %>, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Server.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Server.Finch},
      # Start a worker by calling: Server.Worker.start_link(arg)
      # {Server.Worker, arg},
      # Start to serve requests, typically the last entry
      Server.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Server.Endpoint.config_change(changed, removed)
    :ok
  end
end
