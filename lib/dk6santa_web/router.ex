defmodule Dk6santaWeb.Router do
  use Dk6santaWeb, :router
  use Plug.ErrorHandler

  pipeline :verify_sender do
    plug :accepts, ["json"]
  end

  scope "/", Dk6santaWeb do
    pipe_through :verify_sender

    post("/letter", LetterController, :create)
    post("/shuffle", ShuffleController, :start_shuffle)
  end
end
