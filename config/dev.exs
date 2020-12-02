use Mix.Config

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :dk6santa, Dk6santa.Repo,
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  port: (System.get_env("DB_PORT") || 5432) |> String.to_integer,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASS")

