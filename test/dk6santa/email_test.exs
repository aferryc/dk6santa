defmodule Dk6santa.EmailTest do
  use Dk6santa.DataCase
  use Mimic

  alias Dk6santa.Email
  alias Dk6santa.Mail

  setup :verify_on_exit!

  describe "forward_directly" do
    @santa_attrs %{email: "santa@mail.com", name: "some santa"}
    @kid_attrs %{email: "kid@mail.com", name: "some kid"}

    def email_fixture() do
      {:ok, santa} = @santa_attrs |> Mail.create_contact()
      {:ok, kid} = @kid_attrs |> Map.put(:santa_id, santa.id) |> Mail.create_contact()
      {kid, santa}
    end

    test "should do nothing when not allowed to send email" do
      Dk6santa.Helper
      |> expect(:env, fn :can_send_email -> false end)

      assert %{
               html: "<h1>Hello Worlds</h1>",
               plain: "Hello Worlds",
               subject: "a subject",
               contact_id: 1,
               to_santa: true
             }
             |> Email.forward_directly()
             |> is_nil()
    end

    test "should generate email to santa normally when send allowed" do
      set_mimic_global()
      {kid, _santa} = email_fixture()
      service_mail = Dk6santa.Helper.env(:service_email)

      Dk6santa.Helper
      |> expect(:env, fn :can_send_email -> true end)

      kid_name = kid.name

      Dk6santa.Mailer
      |> expect(:deliver, fn mail ->
        assert %Swoosh.Email{
                 from: {^kid_name, ^service_mail},
                 html_body: "<h1>Hello Worlds</h1>",
                 subject: "a subject",
                 to: [{"some santa", "santa@mail.com"}]
               } = mail
      end)

      %{
        html: "<h1>Hello Worlds</h1>",
        plain: "Hello Worlds",
        subject: "a subject",
        contact_id: kid.id,
        to_santa: true
      }
      |> Email.forward_directly()
    end

    test "should generate email from santa normally when send allowed" do
      {_kid, santa} = email_fixture()
      service_mail = Dk6santa.Helper.env(:service_email)

      Dk6santa.Helper
      |> expect(:env, fn :can_send_email -> true end)

      Dk6santa.Mailer
      |> expect(:deliver, fn mail ->
        assert %Swoosh.Email{
                 from: {"Santa Claus", ^service_mail},
                 html_body: "<h1>Hello Worlds</h1>",
                 subject: "a subject",
                 to: [{"some kid", "kid@mail.com"}]
               } = mail
      end)

      %{
        html: "<h1>Hello Worlds</h1>",
        plain: "Hello Worlds",
        subject: "a subject",
        contact_id: santa.id,
        to_santa: false
      }
      |> Email.forward_directly()
    end

    test "should do nothing if any of the data is missing" do
      Dk6santa.Helper
      |> expect(:env, fn :can_send_email -> true end)

      assert nil |> Dk6santa.Email.forward_directly() |> is_nil()

      assert %{
               html: "<h1>Hello Worlds</h1>",
               plain: "Hello Worlds",
               subject: "a subject",
               contact_id: 3_412_412,
               to_santa: true
             }
             |> Dk6santa.Email.forward_directly()
             |> is_nil()

      assert %{
               html: "<h1>Hello Worlds</h1>",
               plain: "Hello Worlds",
               subject: "a subject",
               contact_id: 3_412_412,
               to_santa: false
             }
             |> Email.forward_directly()
             |> is_nil()
    end
  end
end
