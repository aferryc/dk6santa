defmodule Dk6santa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Dk6santaWeb.Telemetry,
      {Dk6santa.Repo, []},
      {Phoenix.PubSub, name: Dk6santa.PubSub},
      Dk6santaWeb.Endpoint
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
