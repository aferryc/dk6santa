defmodule Dk6santa.Mail.Letter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "letters" do
    field(:html, :string)
    field(:plain, :string)
    field(:subject, :string)
    field(:contact_id, :id)
    field(:to_santa, :boolean)
    field(:sent, :boolean)

    timestamps()
  end

  @doc false
  def changeset(letter, attrs) do
    letter
    |> cast(attrs, [:html, :plain, :subject, :contact_id, :to_santa, :sent])
    |> validate_required([:html, :plain, :subject, :contact_id, :to_santa])
  end
end
