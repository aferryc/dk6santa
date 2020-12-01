defmodule Dk6santa.Mail.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field(:email, :string)
    field(:name, :string)
    field(:uuid, Ecto.UUID, autogenerate: true)

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
  end
end
