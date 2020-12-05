defmodule Dk6santaWeb.Router do
  use Dk6santaWeb, :router
  use Plug.ErrorHandler
  import Plug.BasicAuth

  alias Dk6santa.Helper

  pipeline :authorize do
    plug :accepts, ["json"]

    plug :basic_auth,
      username: Helper.env(:basic_user),
      password: Helper.env(:basic_pass)
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
