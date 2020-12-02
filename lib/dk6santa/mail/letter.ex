defmodule Dk6santa.Mail.Letter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "letters" do
    field(:html, :string)
    field(:plain, :string)
    field(:subject, :string)
    field(:contact_id, :id)

    timestamps()
  end

  @doc false
  def changeset(letter, attrs) do
    letter
    |> cast(attrs, [:html, :plain, :subject, :contact_id])
    |> validate_required([:html, :plain, :subject, :contact_id])
  end
end
