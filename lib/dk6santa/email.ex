defmodule Dk6santa.Email do
  import Swoosh.Email

  alias Dk6santa.Helper

  def send_to_all_santa() do
    Dk6santa.Mail.list_contacts()
    |> Enum.each(fn kid ->
      if kid.santa_id |> is_number() do
        santa = Dk6santa.Mail.get_contact_by_santa(kid.santa_id)

        Dk6santa.Mail.get_all_unsent_letter(kid.id)
        |> Enum.each(fn letter ->
          if letter.to_santa do
            generate_mail(kid, santa, letter)
            |> deliver(letter.id)

            jitter = :rand.uniform(1_000)
            :timer.sleep(1_000 + jitter)
          else
            :ok
          end
        end)
      end
    end)
  end

  def forward_directly(email) do
    forward_directly(email, Helper.env(:can_send_email))
  end

  defp forward_directly(_email, false), do: nil
  defp forward_directly(nil, _can_send), do: nil

  defp forward_directly(%{to_santa: true, contact_id: contact_id} = email, true) do
    with %{santa_id: santa_id} = kid <- Dk6santa.Mail.get_contact!(contact_id),
         %{email: _email} = santa <- Dk6santa.Mail.get_contact!(santa_id),
         %{html: _html} = letter <- %Dk6santa.Mail.Letter{} |> Map.merge(email) do
      generate_mail(kid, santa, letter) |> deliver(letter.id)
    else
      _error ->
        nil
    end
  end

  defp forward_directly(%{to_santa: false, contact_id: contact_id} = email, true) do
    with %{id: santa_id} = santa <- Dk6santa.Mail.get_contact!(contact_id),
         %{email: _email} = kid <- Dk6santa.Mail.get_contact_by_santa(santa_id),
         %{html: _html} = letter <- %Dk6santa.Mail.Letter{} |> Map.merge(email) do
      generate_mail(santa, kid, letter) |> deliver(letter.id)
    else
      _error ->
        nil
    end
  end

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
    |> to({receiver.name, receiver.email})
    |> from({sender, Helper.env(:service_email)})
    |> subject(letter.subject)
    |> html_body(letter.html)
  end

  defp deliver(mail, letter_id) when letter_id |> is_nil() do
    mail |> Dk6santa.Mailer.deliver()
  end

  defp deliver(mail, letter_id) do
    mail
    |> Dk6santa.Mailer.deliver()
    |> case do
      :ok ->
        Dk6santa.Mail.mark_sent(letter_id)

      _ ->
        :error
    end
  end
end
