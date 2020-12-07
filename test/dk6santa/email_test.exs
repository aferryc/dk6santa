defmodule Dk6santa.EmailTest do
  use Dk6santa.DataCase
  use Mimic

  alias Dk6santa.Email
  alias Dk6santa.Mail

  setup :verify_on_exit!

  describe "send_to_all_santa" do
    test "should send all unsent letter to santa" do
      {:ok, santa1} = %{email: "santa1@mail.com", name: "santa1"} |> Mail.create_contact()
      {:ok, santa2} = %{email: "santa2@mail.com", name: "santa2"} |> Mail.create_contact()
      {:ok, santa3} = %{email: "santa3@mail.com", name: "santa3"} |> Mail.create_contact()

      {:ok, kid1} =
        %{email: "kid1@mail.com", name: "kid1", santa_id: santa1.id} |> Mail.create_contact()

      {:ok, kid2} =
        %{email: "kid2@mail.com", name: "kid2", santa_id: santa2.id} |> Mail.create_contact()

      {:ok, _kid3} =
        %{email: "kid3@mail.com", name: "kid3", santa_id: santa3.id} |> Mail.create_contact()

      {:ok, letter1} =
        %{html: "1", plain: "1", subject: "1", contact_id: kid1.id, to_santa: true}
        |> Mail.add_letter()

      {:ok, _letter11} =
        %{html: "11", plain: "11", subject: "1", contact_id: kid1.id, to_santa: false}
        |> Mail.add_letter()

      {:ok, letter2} =
        %{html: "2", plain: "2", subject: "2", contact_id: kid2.id, to_santa: true}
        |> Mail.add_letter()

      {:ok, letter21} =
        %{html: "21", plain: "21", subject: "2", contact_id: kid2.id, to_santa: true}
        |> Mail.add_letter()

      service_mail = Dk6santa.Helper.env(:service_email)

      Dk6santa.Mailer
      |> expect(:deliver, 1, fn %{html_body: "1"} = mail ->
        assert {kid1.name, service_mail} == mail.from
        :ok
      end)
      |> expect(:deliver, 1, fn %{html_body: "2"} = mail ->
        assert {kid2.name, service_mail} == mail.from
        :ok
      end)
      |> expect(:deliver, 1, fn %{html_body: "21"} = mail ->
        assert {kid2.name, service_mail} == mail.from
        :ok
      end)

      letter1_id = letter1.id
      letter2_id = letter2.id
      letter21_id = letter21.id

      Dk6santa.Mail
      |> expect(:mark_sent, 1, fn ^letter1_id -> :ok end)
      |> expect(:mark_sent, 1, fn ^letter2_id -> :ok end)
      |> expect(:mark_sent, 1, fn ^letter21_id -> :ok end)

      Dk6santa.Email.send_to_all_santa()
    end
  end

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
