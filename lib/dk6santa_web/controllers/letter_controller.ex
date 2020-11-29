defmodule Dk6santaWeb.LetterControler do
  use Dk6santaWeb, :controller

  def create(
        conn,
        %{
          "envelope" => envelope,
          "headers" => headers,
          "plain" => plain,
          "html" => html,
          "attachments" => attachments
        } = _params
      ) do
    envelope_id = Dk6santaWeb.MailBook.add(envelope)
    Dk6santaWeb.MailBox.store(envelope_id, %{html: html, plain: plain, attachments: attachments})

    conn |> send_resp(201, "Created")
  end
end
