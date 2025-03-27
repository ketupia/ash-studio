defmodule AshMcp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshMcpWeb.Telemetry,
      AshMcp.Repo,
      {DNSCluster, query: Application.get_env(:ash_mcp, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AshMcp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AshMcp.Finch},
      # Start a worker by calling: AshMcp.Worker.start_link(arg)
      # {AshMcp.Worker, arg},
      # Start to serve requests, typically the last entry
      AshMcpWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :ash_mcp]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshMcp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshMcpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
