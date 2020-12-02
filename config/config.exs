# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dk6santa, Dk6santa.Repo,
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  port: (System.get_env("DB_PORT") || "5432") |> String.to_integer(),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASS")

config :dk6santa,
  ecto_repos: [Dk6santa.Repo],
  basic_user: System.get_env("BASIC_USER"),
  basic_pass: System.get_env("BASIC_PASS"),
  service_email: System.get_env("SERVICE_EMAIL")

# Configures the endpoint
config :dk6santa, Dk6santaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KRmF3+RD3wyau0ghIva1LsSBaYCXUXVPkpHot3d5cbyoyPXxovK7/BjW3+XRba3Q",
  render_errors: [view: Dk6santaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Dk6santa.PubSub

config :dk6santa, Dk6santa.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: System.get_env("SMTP_SERVER"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  ssl: true,
  auth: :always,
  port: 465

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
