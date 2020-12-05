defmodule Dk6santaWeb.LetterController do
  use Dk6santaWeb, :controller
  require Logger

  def create(
        conn,
        %{
          "headers" => %{"from" => header_email, "subject" => subject},
          "plain" => plain
        } = params
      ) do
    Logger.info("Received #{inspect(params)}")
    [email | name] = header_email |> String.split() |> Enum.reverse()
    email = email |> String.replace_leading("<", "") |> String.replace_trailing(">", "")

    name =
      if name |> Enum.empty?() do
        email
      else
        name |> Enum.reverse() |> Enum.join(" ")
      end

    html =
      Map.get(params, "html")
      |> case do
        nil -> plain
        "" -> plain
        html -> html
      end

    plain = params["reply_plain"] || plain

    to_santa = to_santa?(plain)

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
        conn |> send_resp(201, "Cannot be processed")
    end
  end

  def create(conn, params) do
    Logger.warn("Received #{inspect(params)}")
    conn |> send_resp(201, "Not Found")
  end

  defp to_santa?(plain) do
    Regex.match?(~r/dear santa/i, plain)
  end
end
