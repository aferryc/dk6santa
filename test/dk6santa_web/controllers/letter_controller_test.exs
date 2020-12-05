defmodule Dk6santaWeb.LetterControllerTest do
  use Dk6santaWeb.ConnCase
  use Mimic

  setup :verify_on_exit!

  describe "POST /letter" do
    test "should always return 201 if all the params is correct", %{conn: conn} do
      Dk6santa.Mail
      |> expect(:create_contact, fn attrs ->
        assert attrs.email == "sit@dolor.amet"
        assert attrs.name == "Sender Name"
        result = %Dk6santa.Mail.Contact{} |> Map.merge(attrs) |> Map.put(:id, 123)
        {:ok, result}
      end)
      |> expect(:add_letter, fn attrs ->
        assert attrs.html == "<html><body>An email</body></html>"
        assert attrs.plain == "An email"
        assert attrs.subject == "A subject"
        assert attrs.contact_id == 123
        refute attrs.to_santa
        {:ok, %{}}
      end)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "Sender Name <sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "An email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should always return 201 when request is incomplete", %{conn: conn} do
      reject(&Dk6santa.Mail.create_contact/1)
      reject(&Dk6santa.Mail.add_letter/1)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          plain: "An email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should store reply_plain instead of plain if exist", %{conn: conn} do
      Dk6santa.Mail
      |> expect(:create_contact, fn _attrs ->
        result = %Dk6santa.Mail.Contact{} |> Map.put(:id, 864)
        {:ok, result}
      end)
      |> expect(:add_letter, fn attrs ->
        assert attrs.plain == "Reply plain"
        {:ok, %{}}
      end)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "Sender Name <sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "An email",
          reply_plain: "Reply plain",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should set to_santa to true when 'dear santa' in plain", %{conn: conn} do
      Dk6santa.Mail
      |> expect(:create_contact, fn _attrs ->
        result = %Dk6santa.Mail.Contact{} |> Map.put(:id, 762)
        {:ok, result}
      end)
      |> expect(:add_letter, fn attrs ->
        assert attrs.plain == "Dear Santa,\nAn email"
        assert attrs.to_santa
        {:ok, %{}}
      end)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "Sender Name <sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "Dear Santa,\nAn email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should set to_santa to true when 'dear santa' in reply_plain", %{conn: conn} do
      Dk6santa.Mail
      |> expect(:create_contact, fn _attrs ->
        result = %Dk6santa.Mail.Contact{} |> Map.put(:id, 612)
        {:ok, result}
      end)
      |> expect(:add_letter, fn attrs ->
        assert attrs.plain == "Dear Santa,\nReply email"
        assert attrs.to_santa
        {:ok, %{}}
      end)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "Sender Name <sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "An email\nYour santa",
          reply_plain: "Dear Santa,\nReply email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should store email when from don't include name", %{conn: conn} do
      Dk6santa.Mail
      |> expect(:create_contact, fn attrs ->
        assert attrs.name == "sit@dolor.amet"
        result = %Dk6santa.Mail.Contact{} |> Map.put(:id, 431)
        {:ok, result}
      end)
      |> expect(:add_letter, fn _attrs ->
        {:ok, %{}}
      end)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "sit@dolor.amet",
            subject: "A subject"
          },
          plain: "An email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should store contact if name don't have last name", %{conn: conn} do
      Dk6santa.Mail
      |> expect(:create_contact, fn attrs ->
        assert attrs.name == "Lorem"
        result = %Dk6santa.Mail.Contact{} |> Map.put(:id, 3412)
        {:ok, result}
      end)
      |> expect(:add_letter, fn _attrs ->
        {:ok, %{}}
      end)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "Lorem <sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "An email",
          html: "<html><body>An email</body></html>"
        )

      assert response(conn, 201)
    end

    test "should be ok if html was nil", %{conn: conn} do
      Dk6santa.Mail
      |> expect(:create_contact, fn _attrs ->
        result = %Dk6santa.Mail.Contact{} |> Map.put(:id, 3412)

        {:ok, result}
      end)
      |> expect(:add_letter, fn attrs ->
        assert attrs.html == "An email"
        {:ok, %{}}
      end)

      conn =
        conn
        |> put_req_header(
          "authorization",
          TestHelper.basic_auth_token()
        )
        |> post(
          "/letter",
          headers: %{
            from: "Lorem <sit@dolor.amet>",
            subject: "A subject"
          },
          plain: "An email"
        )

      assert response(conn, 201)
    end
  end
end
