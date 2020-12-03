defmodule Dk6santaWeb.LetterController do
  use Dk6santaWeb, :controller
  require Logger

  def create(
        conn,
        %{
          "headers" => %{"from" => header_email, "subject" => subject},
          "plain" => plain,
          "html" => html
        } = params
      ) do
    Logger.info("Received #{inspect(params)}")
    [email | name] = header_email |> String.split() |> Enum.reverse()
    email = email |> String.replace_leading("<", "") |> String.replace_trailing(">", "")

    name =
      if name |> is_nil() do
        email
      else
        name |> Enum.reverse() |> Enum.join(" ")
      end

    to_santa = to_santa?(params["reply_plain"], plain)

    with {:ok, contact} <- %{email: email, name: name} |> Dk6santa.Mail.create_contact(),
         {:ok, _} <-
           %{
             html: html,
             plain: plain,
             subject: subject,
             contact_id: contact.id,
             to_santa: to_santa
           }
           |> Dk6santa.Mail.add_letter() do
      conn |> send_resp(201, "Created")
    else
      {:error, reason} ->
        Logger.error("Error found #{inspect(reason)}")
        conn |> send_resp(400, "Cannot be processed")
    end
  end

  def create(conn, params) do
    Logger.warn("Received #{inspect(params)}")
    conn |> send_resp(404, "Not Found")
  end

  defp to_santa?(nil, plain) do
    Regex.match?(~r/dear santa/i, plain)
  end

  defp to_santa?(reply_plain, _plain) when reply_plain |> is_binary() do
    Regex.match?(~r/dear santa/i, reply_plain)
  end

  defp to_santa?(_, _), do: true
end
