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
      {:ok, kid} = @kid_attrs |> Map.put(santa_id, santa.id) |> Mail.create_contact()
      {kid, santa}
    end

    test "should generate email to santa normally when send allowed" do
      {kid, santa} = email_fixture()

      Application
      |> expect(:get_env, fn :dksanta, :can_send_email -> true end)

      Dk6santa.Mailer
      |> expect(:deliver, fn mail ->
       assert %Swoosh.Email{
               from: {kid.name, ^service_mail},
               html_body: "<h1>Hello Worlds</h1>",
               subject: "a subject",
               to: [{"some santa", "santa@mail.com"}]
             } = mail
      end)

      {kid, santa} = email_fixture()
      %{
          html: "<h1>Hello Worlds</h1>",
          plain: "Hello Worlds",
          subject: "a subject",
          contact_id: kid.id,
          to_santa: true
       } |> Dk6santa.Email.forward_directly()
    end
  end

  describe "forward_directly" do
    test "should able to generate email manually" do

      {:ok, _letter} =
        %{
          html: "<h1>Hello Worlds</h1>",
          plain: "Hello Worlds",
          subject: "a subject",
          contact_id: kid.id
        }
        |> Mail.add_letter()

      service_mail = Application.get_env(:dk6santa, :service_email)

      assert %Swoosh.Email{
               from: {"Your Favourite Elf", ^service_mail},
               html_body: "<h1>Hello Worlds</h1>",
               subject: "Another letter from this kid called some kid",
               to: [{"some santa", "santa@mail.com"}]
             } = Email.generate_mail(kid, santa)
    end
  end
end
