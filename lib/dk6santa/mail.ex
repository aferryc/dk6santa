defmodule Dk6santa.Mail do
  import Ecto.Query, warn: false

  alias Dk6santa.Repo

  alias Dk6santa.Mail.Contact

  def list_contacts do
    Repo.all(Contact)
  end

  def get_contact!(id), do: Repo.get!(Contact, id)

  def get_contact_by_email(email), do: Repo.get_by(Contact, email: email)

  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
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

  def add_letter(attrs \\ %{}) do
    %Letter{}
    |> Letter.changeset(attrs)
    |> Repo.insert()
  end
end
