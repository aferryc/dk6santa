defmodule Dk6santaWeb.Router do
  use Dk6santaWeb, :router
  use Plug.ErrorHandler
  import Plug.BasicAuth

  pipeline :authorize do
    plug :accepts, ["json"]

    plug :basic_auth,
      username: Application.get_env(:dk6santa, :basic_user),
      password: Application.get_env(:dk6santa, :basic_pass)
  end

  scope "/", Dk6santaWeb do
    get("/health", PageController, :health)
  end

  scope "/", Dk6santaWeb do
    pipe_through :authorize

    post("/letter", LetterController, :create)
  end

  def handle_errors(conn, _error) do
    conn
    |> send_resp(404, "Not Found")
  end
end
