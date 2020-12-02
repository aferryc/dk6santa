defmodule Dk6santa.EmailTest do
  use Dk6santa.DataCase

  alias Dk6santa.Email
  alias Dk6santa.Mail

  describe "generate_mail" do
    test "should able to generate email manually" do
      {:ok, kid} = %{email: "kid@mail.com", name: "some kid"} |> Mail.create_contact()
      {:ok, santa} = %{email: "santa@mail.com", name: "some santa"} |> Mail.create_contact()

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
