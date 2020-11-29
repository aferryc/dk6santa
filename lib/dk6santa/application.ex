defmodule Dk6santa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Dk6santa.Repo,
      # Start the Telemetry supervisor
      Dk6santaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Dk6santa.PubSub},
      # Start the Endpoint (http/https)
      Dk6santaWeb.Endpoint
      # Start a worker by calling: Dk6santa.Worker.start_link(arg)
      # {Dk6santa.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dk6santa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Dk6santaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
