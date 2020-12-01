defmodule Dk6santaWeb.LetterControllerTest do
  use Dk6santaWeb.ConnCase

  describe "POST /letter" do
    test "should always return 201 if all the params is correct", %{conn: conn} do
      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          envelope: %{
            from: "sit@dolor.amet"
          },
          headers: %{
            from: "Sender Name<sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "An email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should always return 404 when request is incomplete", %{conn: conn} do
      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "Sender Name<sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "An email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 404)
    end
  end
end
