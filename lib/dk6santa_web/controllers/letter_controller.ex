defmodule Dk6santaWeb.LetterController do
  use Dk6santaWeb, :controller

  def create(
        conn,
        %{
          "envelope" => %{"from" => email},
          "headers" => %{"from" => header_email, "subject" => subject},
          "plain" => plain,
          "html" => html
        } = _params
      ) do
    [name | _rest] = header_email |> String.split("<")

    with {:ok, contact} <- %{email: email, name: name} |> Dk6santa.Mail.create_contact(),
         {:ok, _} <-
           %{html: html, plain: plain, subject: subject, contact_id: contact.id}
           |> Dk6santa.Mail.add_letter() do
      conn |> send_resp(201, "Created")
    else
      {:error, reason} ->
        IO.inspect(reason)
        conn |> send_resp(400, "Cannot be processed")
    end
  end

  def create(conn, _), do: conn |> send_resp(404, "Not Found")
end
