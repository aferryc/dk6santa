defmodule Dk6santaWeb.PageControllerTest do
  use Dk6santaWeb.ConnCase
  use Mimic

  setup :verify_on_exit!

  describe "GET /healthz" do
    test "should return 200 when test query is ok", %{conn: conn} do
      Ecto.Adapters.SQL
      |> expect(:query, fn Dk6santa.Repo, "select 1", [] -> :ok end)

      conn =
        conn
        |> get("/health")

      assert response(conn, 200)
    end

    test "should return 500 when test query raise error", %{conn: conn} do
      Ecto.Adapters.SQL
      |> expect(:query, fn Dk6santa.Repo, "select 1", [] -> raise DBConnection.ConnectionError end)

      conn =
        conn
        |> get("/health")

      assert response(conn, 500)
    end
  end
end
