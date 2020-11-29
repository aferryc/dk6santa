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
            to: "foo@bar.com",
            recipients: ["some@mail.com"],
            from: "sit@dolor.amet"
          },
          headers: %{
            return_path: "sit@dolor.amet",
            from: "Sender <sit@dolor.amet>",
            to: "Receiver <foo@bar.com>",
            message_id: "something@example.mail",
            subject: "A subject"
          },
          plain: "An email",
          html: "<html><body>An email</body></html>",
          attachments: [
            %{
              content: "dGVzdGZpbGU=",
              file_name: "file.txt",
              content_type: "text/plain",
              size: 8,
              disposition: "attachment"
            }
          ]
        )

      assert response(conn, 201)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          envelope: %{
            to: "foo@bar.com",
            recipients: ["some@mail.com"],
            from: "sit@dolor.amet"
          },
          headers: %{
            return_path: "sit@dolor.amet",
            from: "Sender <sit@dolor.amet>",
            to: "Receiver <foo@bar.com>",
            message_id: "something@example.mail",
            subject: "A subject"
          },
          plain: "An email",
          html: "<html><body>An email</body></html>",
          attachments: [
            %{
              content: "dGVzdGZpbGU=",
              file_name: "file.txt",
              content_type: "text/plain",
              size: 8,
              disposition: "attachment"
            }
          ]
        )

      assert response(conn, 201)
    end
  end
end
