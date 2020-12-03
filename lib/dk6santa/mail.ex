defmodule Dk6santa.Mail do
  import Ecto.Query, warn: false

  alias Dk6santa.Repo

  alias Dk6santa.Mail.Contact

  def list_contacts do
    Repo.all(Contact)
  end

  def get_contact!(id), do: Repo.get!(Contact, id)

  def get_contact_by_santa(santa_id), do: Repo.get_by(Contact, santa_id: santa_id)

  def get_contact_by_email(email), do: Repo.get_by(Contact, email: email)

  def create_contact(attrs \\ %{}) do
    case Dk6santa.Mail.get_contact_by_email(attrs.email) do
      nil ->
        %Contact{}
        |> Contact.changeset(attrs)
        |> Repo.insert(on_conflict: :nothing)

      contact ->
        {:ok, contact}
    end
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
    Dk6santa.Email.forward_directly(letter)

    %Letter{}
    |> Letter.changeset(letter)
    |> Repo.insert()
  end
end
