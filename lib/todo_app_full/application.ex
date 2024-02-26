defmodule TodoAppFull.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

    Appsignal.Phoenix.LiveView.attach()
    # Appsignal.Logger.Handler.add("Index Page")

    children = [
      TodoAppFullWeb.Telemetry,
      TodoAppFull.Repo,
      {DNSCluster, query: Application.get_env(:todo_app_full, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TodoAppFull.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TodoAppFull.Finch},
      # Start a worker by calling: TodoAppFull.Worker.start_link(arg)
      # {TodoAppFull.Worker, arg},
      # Start to serve requests, typically the last entry
      TodoAppFullWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TodoAppFull.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TodoAppFullWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
