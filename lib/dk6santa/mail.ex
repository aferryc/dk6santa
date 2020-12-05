defmodule Dk6santa.Mail do
  import Ecto.Query, warn: false

  alias Dk6santa.Repo

  alias Dk6santa.Mail.Contact

  def list_contacts do
    Repo.all(Contact)
  end

  def get_contact!(id), do: Repo.get!(Contact, id)

  def get_contact_by_santa(santa_id) when santa_id |> is_integer,
    do: Repo.get_by(Contact, santa_id: santa_id)

  def get_contact_by_santa(nil), do: nil

  def get_contact_by_email(email) when email |> is_binary, do: Repo.get_by(Contact, email: email)
  def get_contact_by_email(nil), do: nil

  def create_contact(%{email: email} = attrs) when email |> is_binary do
    case Dk6santa.Mail.get_contact_by_email(email) do
      nil ->
        %Contact{}
        |> Contact.changeset(attrs)
        |> Repo.insert(on_conflict: :nothing)

      contact ->
        {:ok, contact}
    end
  end

  def create_contact(_attrs), do: {:error, :invalid_attrs}

  def assign_santa(id, santa_id) do
    Repo.get!(Contact, id)
    |> Contact.changeset(%{santa_id: santa_id})
    |> Repo.update()
  end

  alias Dk6santa.Mail.Letter

  def list_letters do
    Repo.all(Letter)
  end

  def get_all_letter(contact_id) do
    query = from(l in Letter, where: l.contact_id == ^contact_id)
    Repo.all(query)
  end

  def get_letter!(id), do: Repo.get!(Letter, id)

  def add_letter(letter \\ %{}) do
    %Letter{}
    |> Letter.changeset(letter)
    |> Repo.insert()
    |> case do
      {:ok, letter} ->
        Dk6santa.Helper.spawn_func(fn ->
          Dk6santa.Email.forward_directly(letter)
        end)

        {:ok, letter}

      other ->
        other
    end
  end
end
