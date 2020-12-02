defmodule Dk6santaWeb.PageController do
  use Dk6santaWeb, :controller

  def health(conn, _param) do
    Ecto.Adapters.SQL.query(Dk6santa.Repo, "select 1", [])
    conn |> send_resp(200, "ok")
  rescue
    DBConnection.ConnectionError ->
      conn |> send_resp(500, "Not ok")
  end
end
