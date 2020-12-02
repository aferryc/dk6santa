defmodule Dk6santa.Email do
  import Swoosh.Email

  def generate_mail(%Dk6santa.Mail.Contact{} = kid, %Dk6santa.Mail.Contact{} = santa) do
    letters = Dk6santa.Mail.get_all_letter(kid.id)
    letter = letters |> List.first()

    new()
    |> to({santa.name, santa.email})
    |> from({"Your Favourite Elf", service_email()})
    |> subject("Another letter from this kid called #{kid.name}")
    |> html_body(letter.html)
  end

  defp service_email, do: Application.get_env(:dk6santa, :service_email)
end
