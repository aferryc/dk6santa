defmodule Dk6santa.Mail.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field(:email, :string)
    field(:name, :string)
    field(:uuid, Ecto.UUID, autogenerate: true)
    field(:santa_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    attrs =
      if contact.id |> is_integer() do
        attrs |> Map.put(:current_id, contact.id)
      else
        attrs
      end

    contact
    |> cast(attrs, [:name, :email, :santa_id])
    |> validate_required([:name, :email])
    |> validate_santa_id(attrs)
  end

  def validate_santa_id(changeset, %{current_id: current_id, santa_id: santa_id} = params)
      when current_id == santa_id do
    add_error(changeset, :wrong_santa_id, "Santa ID cannot be the same as current user")
  end

  def validate_santa_id(changeset, _any), do: changeset
end
