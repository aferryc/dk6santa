defmodule Dk6santaWeb.PageController do
  use Dk6santaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
