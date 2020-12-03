defmodule Dk6santa.Email do
  import Swoosh.Email

  def forward_directly(email) do
    forward_directly(email, can_send?())
  end

  defp forward_directly(_email, false), do: nil

  defp forward_directly(%{to_santa: true} = email, true) do
    kid = Dk6santa.Mail.get_contact!(email.contact_id)
    santa = Dk6santa.Mail.get_contact!(kid.santa_id)
    letter = %Dk6santa.Mail.Letter{} |> Enum.into(email)
    generate_mail(kid, santa, letter) |> Dk6santa.Mailer.deliver()
  end

  defp forward_directly(%{to_santa: false} = email, true) do
    santa = Dk6santa.Mail.get_contact!(email.contact_id)
    kid = Dk6santa.Mail.get_contact_by_santa(santa.id)
    letter = %Dk6santa.Mail.Letter{} |> Enum.into(email)
    generate_mail(santa, kid, letter) |> Dk6santa.Mailer.deliver()
  end

  defp generate_mail(kid, santa, letter)
       when kid |> is_nil() or santa |> is_nil() or letter |> is_nil(),
       do: nil

  defp generate_mail(
         %Dk6santa.Mail.Contact{} = sender,
         %Dk6santa.Mail.Contact{} = receiver,
         %Dk6santa.Mail.Letter{} = letter
       ) do
    sender =
      if letter.to_santa do
        sender.name
      else
        "Santa Claus"
      end

    new()
    |> to({santa.name, santa.email})
    |> from({sender, service_email()})
    |> subject(letter.subject)
    |> html_body(letter.html)
  end

  defp service_email, do: Application.get_env(:dk6santa, :service_email)
  defp can_send?(), do: Application.get_env(:dk6santa, :can_send_email)
end
