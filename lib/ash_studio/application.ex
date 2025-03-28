defmodule AshStudio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshStudioWeb.Telemetry,
      AshStudio.Repo,
      {DNSCluster, query: Application.get_env(:ash_studio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AshStudio.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AshStudio.Finch},
      # Start a worker by calling: AshStudio.Worker.start_link(arg)
      # {AshStudio.Worker, arg},
      # Start to serve requests, typically the last entry
      AshStudioWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :ash_studio]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshStudio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshStudioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
