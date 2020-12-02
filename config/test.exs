use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :dk6santa, sql_sandbox: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dk6santa, Dk6santaWeb.Endpoint,
  http: [port: 4002],
  server: false

config :dk6santa, Dk6santa.Repo,
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  port: (System.get_env("DB_PORT") || "5432") |> String.to_integer(),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASS"),
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn
