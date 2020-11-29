defmodule Dk6santa.Repo do
  use Ecto.Repo,
    otp_app: :dk6santa,
    adapter: Ecto.Adapters.Postgres
end
